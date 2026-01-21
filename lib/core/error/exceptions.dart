class ImageNotFoundException implements Exception {
  ImageNotFoundException(this.url);

  final String url;

  @override
  String toString() => 'ImageNotFoundException: Image not found at $url';
}
