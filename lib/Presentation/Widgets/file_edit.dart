import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../Common/Helper/file_type.dart';
import '../Bloc/files/files_bloc.dart';

class FileViewerPage extends StatefulWidget {
  final String path;
  final String content;
  final bool startInEdit;

  const FileViewerPage({
    super.key,
    required this.path,
    required this.content,
    required this.startInEdit,
  });

  @override
  State<FileViewerPage> createState() => _FileViewerPageState();
}

class _FileViewerPageState extends State<FileViewerPage> {
  late bool isEdit;
  late TextEditingController controller;
  late FileViewType type;

  @override
  void initState() {
    super.initState();
    isEdit = widget.startInEdit;
    controller = TextEditingController(text: widget.content);
    type = getFileType(widget.path);
  }

  bool get canEdit => type == FileViewType.text || type == FileViewType.code;

  @override
  Widget build(BuildContext context) {
    if (type == FileViewType.unsupported) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cannot preview this file')),
        );
        Navigator.pop(context);
      });
      return const SizedBox();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit File' : 'View File'),
        actions: [
          if (!isEdit && canEdit)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => isEdit = true),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: _buildViewer(),
      ),
      floatingActionButton: isEdit && canEdit
          ? FloatingActionButton(
        onPressed: () {
          context.read<FilesBloc>().add(
            SaveFileContent(widget.path, controller.text),
          );
          Navigator.pop(context);
        },
        child: const Icon(Icons.save),
      )
          : null,
    );
  }

  Widget _buildViewer() {
    switch (type) {
      case FileViewType.image:
        return Center(
          child: Image.network(widget.path), // adjust to your backend loading
        );

      case FileViewType.pdf:
        return const Center(
          child: Text('PDF preview not supported yet'),
        );

      case FileViewType.text:
      case FileViewType.code:
        return TextField(
          controller: controller,
          expands: true,
          maxLines: null,
          readOnly: !isEdit,
          style: TextStyle(
            fontFamily: type == FileViewType.code ? 'monospace' : null,
          ),
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
        );

      default:
        return const SizedBox();
    }
  }
}
