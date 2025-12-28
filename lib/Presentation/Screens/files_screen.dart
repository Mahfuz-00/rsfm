// lib/presentation/screens/files_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../Common/Error/error_handler.dart';
import '../../Core/Dependency Injection/di.dart';
import '../Bloc/files/files_bloc.dart';
import '../Bloc/theme/theme_bloc.dart';



class FilesScreen extends StatefulWidget {
  const FilesScreen({super.key});
  @override
  State<FilesScreen> createState() => _FilesScreenState();
}

class _FilesScreenState extends State<FilesScreen> {
  final _contentController = TextEditingController();
  String? _editingPath;


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // This is the safe place to read GoRouterState
    final extra = GoRouterState.of(context).extra as Map<String, String>?;
    print('Extra : $extra');
    if (extra != null) {
      context.read<FilesBloc>().add(
        InitFiles(extra['url']!, extra['password']!),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<FilesBloc, FilesState>(
      listener: (context, state) {
        if (state is FilesError) ErrorHandler.showError(context, state.message);
        if (state is FileContentLoaded) {
          _contentController.text = state.content;
          _showEditDialog(context);
        }
        if (state is FileContentSaved) {
          Navigator.pop(context);
          context.read<FilesBloc>().add(LoadFiles());
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Remote Files'),
          actions: [
            IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: () {
              context.read<ThemeBloc>().add(ToggleTheme());
            },
            ),
          ],
        ),
        body: BlocBuilder<FilesBloc, FilesState>(
          builder: (context, state) {
            if (state is FilesLoading) return const Center(child: CircularProgressIndicator());
            if (state is FilesLoaded) {
              return ListView.builder(
                itemCount: state.files.length,
                itemBuilder: (_, i) {
                  final file = state.files[i];
                  return ListTile(
                    leading: Icon(file.type == 'folder' ? Icons.folder : Icons.description),
                    title: Text(file.name),
                    subtitle: file.type == 'file' ? Text(file.humanReadableSize ?? '') : null,
                    trailing: PopupMenuButton<String>(
                      onSelected: (v) {
                        if (v == 'delete') context.read<FilesBloc>().add(DeleteItem(file.path));
                        if (v == 'edit') {
                          _editingPath = file.path;
                          context.read<FilesBloc>().add(LoadFileContent(file.path));
                        }
                      },
                      itemBuilder: (_) => [
                        const PopupMenuItem(value: 'delete', child: Text('Delete')),
                        if (file.type == 'file') const PopupMenuItem(value: 'edit', child: Text('Edit')),
                      ],
                    ),
                    onTap: () => file.type == 'folder'
                        ? context.read<FilesBloc>().add(NavigateToPath(file.path))
                        : null,
                  );
                },
              );
            }
            return const Center(child: Text('Tap + to create'));
          },
        ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              heroTag: 'folder',
              onPressed: () => _showCreateDialog(context, true),
              child: const Icon(Icons.create_new_folder),
            ),
            const SizedBox(height: 16),
            FloatingActionButton(
              heroTag: 'file',
              onPressed: () => _showCreateDialog(context, false),
              child: const Icon(Icons.note_add),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateDialog(BuildContext ctx, bool isDir) {
    final controller = TextEditingController();
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: Text('Create ${isDir ? 'Folder' : 'File'}'),
        content: TextField(controller: controller, decoration: const InputDecoration(hintText: 'Name')),
        actions: [
          TextButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                isDir
                    ? ctx.read<FilesBloc>().add(CreateDirectory(name))
                    : ctx.read<FilesBloc>().add(CreateFile(name));
              }
              Navigator.pop(ctx);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext ctx) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('Edit File'),
        content: TextField(controller: _contentController, maxLines: null, expands: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              context.read<FilesBloc>().add(SaveFileContent(_editingPath!, _contentController.text));
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}