import 'package:icons_launcher/constants.dart';
import 'package:icons_launcher/utils.dart';
import 'package:image/image.dart';
import 'package:universal_io/io.dart';

/// File to handle the creation of icons for Windows platform
class WindowsIconTemplate {
  WindowsIconTemplate({required this.size, required this.name});

  final String name;
  final int size;
}

//? https://www.creativefreedom.co.uk/icon-designers-blog/windows-ico/
// Give a highest quality icon with a minimum of 256x256 pixels.
// ico encoder will create multiple sizes of the icon.
// debug ico file here (https://redketchup.io/icon-editor)
List<WindowsIconTemplate> windowsIcons = <WindowsIconTemplate>[
  // WindowsIconTemplate(name: '', size: 16),
  // WindowsIconTemplate(name: '', size: 32),
  // WindowsIconTemplate(name: '', size: 48),
  WindowsIconTemplate(name: '', size: 256),
];

/// Creates icons with resize
Image createResizedImage(WindowsIconTemplate template, Image image) {
  if (image.width >= template.size) {
    return copyResize(image,
        width: template.size,
        height: template.size,
        interpolation: Interpolation.average);
  } else {
    return copyResize(image,
        width: template.size,
        height: template.size,
        interpolation: Interpolation.linear);
  }
}

/// Overwrites the icon file with the new icon
void overwriteDefaultIcons(WindowsIconTemplate template, Image image) {
  final Image newFile = createResizedImage(template, image);
  File(windowsDefaultIconFolder +
      windowsDefaultIconName +
      template.name +
      '.ico')
    ..writeAsBytesSync(encodeIco(newFile));
}

/// Creates new icons
void saveNewIcons(
    WindowsIconTemplate template, Image image, String newIconName) {
  final String newIconFolder = windowsDefaultIconFolder + newIconName;
  final Image newFile = createResizedImage(template, image);
  File(newIconFolder + newIconName + template.name + '.ico')
      .create(recursive: true)
      .then((File file) {
    file.writeAsBytesSync(encodeIco(newFile));
  });
}

/// Create icons
void createIcons(Map<String, dynamic> config, String? flavor) {
  final String filePath = config['image_path_windows'] ?? config['image_path'];
  // decodeImageFile shows error message if null
  // so can return here if image is null
  final Image? image = decodeImage(File(filePath).readAsBytesSync());
  if (image == null) {
    return;
  }

  final dynamic windowsConfig = config['windows'];
  if (windowsConfig is String) {
    // If the Windows configuration is a string then the user has specified a new icon to be created
    // and for the old icon file to be kept
    final String newIconName = windowsConfig;
    printStatus('Adding new Windows launcher icon');
    for (WindowsIconTemplate template in windowsIcons) {
      saveNewIcons(template, image, newIconName);
    }
  } else {
    printStatus('Overwriting default Windows launcher icon with new icon');
    for (WindowsIconTemplate template in windowsIcons) {
      overwriteDefaultIcons(template, image);
    }
  }
}
