import 'dart:io';

void main() {
  final dir = Directory('lib');
  final colorString = 'Color(0xFFDB3022)';
  
  void replaceInFile(File file) {
    String content = file.readAsStringSync();
    bool modified = false;
    
    // Pattern to match CircularProgressIndicator() and CircularProgressIndicator(color: Colors.black) etc.
    // We only need to replace CircularProgressIndicator() 
    if (content.contains('CircularProgressIndicator()')) {
      content = content.replaceAll('CircularProgressIndicator()', 'CircularProgressIndicator(color: const Color(0xFFDB3022))');
      modified = true;
    }
    
    // In loading_overlay.dart, it has valueColor: AlwaysStoppedAnimation<Color>(Colors.white)
    if (file.path.contains('loading_overlay.dart')) {
      if (content.contains('AlwaysStoppedAnimation<Color>(Colors.white)')) {
        content = content.replaceAll('AlwaysStoppedAnimation<Color>(Colors.white)', 'AlwaysStoppedAnimation<Color>(Color(0xFFDB3022))');
        modified = true;
      }
    }

    if (modified) {
      file.writeAsStringSync(content);
      print('Updated: ${file.path}');
    }
  }

  void processDirectory(Directory d) {
    for (var entity in d.listSync()) {
      if (entity is Directory) {
        processDirectory(entity);
      } else if (entity is File && entity.path.endsWith('.dart')) {
        replaceInFile(entity);
      }
    }
  }

  processDirectory(dir);
}
