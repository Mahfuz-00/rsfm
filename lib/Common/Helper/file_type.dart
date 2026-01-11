enum FileViewType { text, code, image, pdf, unsupported }

FileViewType getFileType(String path) {
  final ext = path.split('.').last.toLowerCase();

  // Images
  if (['png', 'jpg', 'jpeg', 'webp', 'gif'].contains(ext)) {
    return FileViewType.image;
  }

  // PDF
  if (ext == 'pdf') return FileViewType.pdf;

  // Code files
  if (['js', 'ts', 'dart', 'py', 'php', 'java', 'cpp', 'c', 'html', 'css', 'json', 'xml', 'yml', 'yaml', 'md'].contains(ext)) {
    return FileViewType.code;
  }

  // Text
  if (['txt', 'log', 'env', 'conf', 'ini'].contains(ext)) {
    return FileViewType.text;
  }

  return FileViewType.unsupported;
}
