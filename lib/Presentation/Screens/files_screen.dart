// lib/presentation/screens/files_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../Common/Error/error_handler.dart';
import '../../Common/Helper/sort_mode.dart';
import '../../Domain/Entities/file_entity.dart';
import '../Bloc/files/files_bloc.dart';
import '../Bloc/theme/theme_bloc.dart';
import '../Widgets/file_edit.dart';
import '../Widgets/file_screens_dialogs.dart';

class FilesScreen extends StatefulWidget {
  const FilesScreen({super.key});

  @override
  State<FilesScreen> createState() => _FilesScreenState();
}

class _FilesScreenState extends State<FilesScreen> {
  final _contentController = TextEditingController();
  String? _editingPath;
  bool _isInitialized = false;
  SortMode _currentSort = SortMode.name;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final extra = GoRouterState.of(context).extra as Map<String, String>?;
      if (extra != null) {
        context.read<FilesBloc>().add(
          InitFiles(extra['url']!, extra['password']!),
        );
      }
      _isInitialized = true;
    }
  }

  List<FileEntity> _sortFiles(List<FileEntity> files) {
    final folders = files.where((f) => f.type == 'folder').toList();
    final fileList = files.where((f) => f.type == 'file').toList();

    if (_currentSort == SortMode.name) {
      folders.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      fileList.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    } else {
      folders.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      fileList.sort((a, b) => (b.size ?? 0).compareTo(a.size ?? 0));
    }

    return [...folders, ...fileList];
  }

  String _formatPathLabel(String path) {
    if (path == '~/home/' || path == '/home/') return './';

    if (path.startsWith('~/home/')) {
      return './' + path.substring('~/home/'.length);
    }

    if (path.startsWith('/home/')) {
      return './' + path.substring('/home/'.length);
    }

    return path;
  }

  bool isLockedRoot(String path) {
    // Normalize
    final p = path.endsWith('/') ? path : '$path/';

    if (!p.startsWith('/home/')) return false;

    final rest = p.substring('/home/'.length); // after /home/
    final parts = rest.split('/').where((e) => e.isNotEmpty).toList();

    // If only one segment like: touchandsolve.com/
    return parts.length <= 1;
  }



  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        final bloc = context.read<FilesBloc>();
        final path = bloc.currentPath;

        // Block back only at real root
        if (isLockedRoot(path)) return;
        bloc.add(NavigateToPath('..'));
      },
      child: BlocListener<FilesBloc, FilesState>(
        listener: (context, state) {
          print('BlocListener received state: ${state.runtimeType}');
          if (state is FilesError) {
            print('FilesError: ${state.message}');
            ErrorHandler.showError(context, state.message);
          }
          if (state is FileContentLoaded) {
            print('FileContentLoaded for path: $_editingPath');
            _contentController.text = state.content;
          }
          if (state is FileContentSaved) {
            print('FileContentSaved - refreshing list');
            Navigator.pop(context);
            context.read<FilesBloc>().add(LoadFiles());
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Files Manager'),
            actions: [
              IconButton(
                icon: Icon(
                  _currentSort == SortMode.name ? Icons.sort_by_alpha : Icons.sort,
                  color: _currentSort == SortMode.name ? Colors.white : null,
                ),
                onPressed: () {
                  setState(() {
                    _currentSort = _currentSort == SortMode.name ? SortMode.size : SortMode.name;
                  });
                },
                tooltip: _currentSort == SortMode.name ? 'Sort by Size' : 'Sort by Name',
              ),
              IconButton(
                icon: const Icon(Icons.brightness_6),
                onPressed: () => context.read<ThemeBloc>().add(ToggleTheme()),
              ),
            ],
          ),
          body: Column(
            children: [
              // Current path at top
              BlocBuilder<FilesBloc, FilesState>(
                builder: (context, state) {
                  final currentPath = context.read<FilesBloc>().currentPath;
                  print('Current path displayed: $currentPath');
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    color: Colors.grey.shade200,
                    child: Text(
                      _formatPathLabel(currentPath),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  );
                },
              ),
              Expanded(
                child: BlocBuilder<FilesBloc, FilesState>(
                  builder: (context, state) {
                    print('BlocBuilder rebuild with state: ${state.runtimeType}');

                    if (state is FilesLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state is FilesLoaded) {
                      final filtered = state.files.where((f) => f.name != '.').toList();
                      final sorted = _sortFiles(filtered);

                      if (sorted.isEmpty) {
                        return const Center(child: Text('This folder is empty\nTap + to create'));
                      }

                      return ListView.builder(
                        itemCount: sorted.length,
                        itemBuilder: (_, i) {
                          final file = sorted[i];

                          // Special ".." row
                          if (file.name == '..') {
                            final path = context.read<FilesBloc>().currentPath;

                            // Hide back item if locked root
                            if (isLockedRoot(path)) {
                              return const SizedBox.shrink();
                            }

                            return ListTile(
                              leading: const Icon(Icons.arrow_upward, color: Colors.blue),
                              title: const Text('Up one level', style: TextStyle(fontWeight: FontWeight.bold)),
                              onTap: () => context.read<FilesBloc>().add(NavigateToPath(file.path)),
                            );
                          }

                          return ListTile(
                            leading: Icon(file.type == 'folder' ? Icons.folder : Icons.description),
                            title: Text(file.name),
                            subtitle: file.type == 'file' ? Text(file.humanReadableSize ?? '') : null,
                            trailing: PopupMenuButton<String>(
                              onSelected: (v) {
                                final bloc = context.read<FilesBloc>();
                                if (v == 'delete') bloc.add(DeleteItem(file.path));
                                if (v == 'edit' && file.type == 'file') {
                                  _editingPath = file.path;
                                  bloc.add(LoadFileContent(file.path));
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => FileViewerPage(
                                        path: file.path,
                                        content: '',
                                        startInEdit: true,
                                      ),
                                    ),
                                  );
                                }
                                if (v == 'rename') {
                                  showDialog(
                                    context: context,
                                    builder: (_) => RenameDialog(file: file),
                                  );
                                }
                                if (v == 'view' && file.type == 'file') {
                                  _editingPath = file.path;
                                  bloc.add(LoadFileContent(file.path));
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => FileViewerPage(
                                        path: file.path,
                                        content: '',
                                        startInEdit: false,
                                      ),
                                    ),
                                  );
                                }
                              },
                              itemBuilder: (_) => [
                                const PopupMenuItem(value: 'delete', child: Text('Delete')),
                                if (file.type == 'file') const PopupMenuItem(value: 'edit', child: Text('Edit')),
                                const PopupMenuItem(value: 'rename', child: Text('Rename')),
                                if (file.type == 'file') const PopupMenuItem(value: 'view', child: Text('View')),
                              ],
                            ),
                            onTap: () {
                              if (file.type == 'folder') {
                                context.read<FilesBloc>().add(NavigateToPath(file.path));
                              } else if (file.type == 'file') {
                                _editingPath = file.path;
                                context.read<FilesBloc>().add(LoadFileContent(file.path));
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => FileViewerPage(
                                      path: file.path,
                                      content: '',
                                      startInEdit: false,
                                    ),
                                  ),
                                );
                              }
                            },
                          );
                        },
                      );
                    }
                    return const Center(child: Text('Tap + to create'));
                  },
                ),
              ),
            ],
          ),
          floatingActionButton: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton(
                heroTag: 'folder',
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => const CreateFolderDialog(),
                ),
                child: const Icon(Icons.create_new_folder),
              ),
              const SizedBox(height: 16),
              FloatingActionButton(
                heroTag: 'file',
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => const CreateFileDialog(),
                ),
                child: const Icon(Icons.note_add),
              ),
            ],
          ),
        ),
      ),
    );
  }
}