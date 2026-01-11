import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../Domain/Entities/file_entity.dart';
import '../Bloc/files/files_bloc.dart';

class CreateFolderDialog extends StatelessWidget {
  const CreateFolderDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.create_new_folder),
          SizedBox(width: 8),
          Text('New Folder'),
        ],
      ),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(hintText: 'Folder name'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            final name = controller.text.trim();
            if (name.isNotEmpty) {
              context.read<FilesBloc>().add(CreateDirectory(name));
            }
            Navigator.pop(context);
          },
          child: const Text('Create'),
        ),
      ],
    );
  }
}

// New widget for Create File dialog
class CreateFileDialog extends StatelessWidget {
  const CreateFileDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.note_add),
          SizedBox(width: 8),
          Text('New File'),
        ],
      ),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(hintText: 'File name (e.g. note.txt)'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            final name = controller.text.trim();
            if (name.isNotEmpty) {
              context.read<FilesBloc>().add(CreateFile(name));
            }
            Navigator.pop(context);
          },
          child: const Text('Create'),
        ),
      ],
    );
  }
}

// New widget for Rename dialog
class RenameDialog extends StatelessWidget {
  final FileEntity file;

  const RenameDialog({super.key, required this.file});

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: file.name);
    return AlertDialog(
      title: const Text('Rename'),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(hintText: 'New name'),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        TextButton(
          onPressed: () {
            final newName = controller.text.trim();
            if (newName.isNotEmpty && newName != file.name) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Rename not supported yet')),
              );
            }
            Navigator.pop(context);
          },
          child: const Text('Rename'),
        ),
      ],
    );
  }
}