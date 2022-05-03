import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:piwigo_ng/services/OrientationService.dart';
import 'package:piwigo_ng/views/components/image_grid_item.dart';

class ImageGrid extends StatelessWidget {
  const ImageGrid({
    Key key, this.isSelected, this.onLongPress, this.onTap, this.imageList
  }) : super(key: key);

  final List<dynamic> imageList;
  final Function(dynamic image, int index) onLongPress;
  final Function(dynamic image, int index) onTap;
  final Function(int id) isSelected;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: getImageCrossAxisCount(context),
        mainAxisSpacing: 3.0,
        crossAxisSpacing: 3.0,
      ),
      padding: EdgeInsets.symmetric(horizontal: 5),
      itemCount: imageList.length,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (BuildContext context, int index) {
        var image = imageList[index];
        return ImageGridItem(
          image: image,
          isSelected: isSelected(image['id']),
          onLongPress: () => onLongPress(image, index),
          onTap: () => onTap(image, index),
        );
      },
    );
  }
}