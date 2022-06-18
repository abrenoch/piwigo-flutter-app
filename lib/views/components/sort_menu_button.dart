import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:piwigo_ng/constants/SettingsConstants.dart';
import 'package:piwigo_ng/model/SortModel.dart';
import 'package:piwigo_ng/views/FavoritesViewPage.dart';
import 'package:piwigo_ng/views/SortedViewPage.dart';
import 'package:piwigo_ng/views/components/dialogs/dialogs.dart';

enum SortMenuOptions { favorites, tags, top_viewed, top_rated, recent }

class SortPopupMenuButton extends StatelessWidget {
  const SortPopupMenuButton({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {


    final sortOptions = [
      appStrings(context).categorySort_nameAscending,
      appStrings(context).categorySort_nameDescending,
      appStrings(context).categorySort_fileNameAscending,
      appStrings(context).categorySort_fileNameDescending,
      appStrings(context).categorySort_dateCreatedDescending,
      appStrings(context).categorySort_dateCreatedAscending,
      appStrings(context).categorySort_datePostedDescending,
      appStrings(context).categorySort_datePostedAscending,
      appStrings(context).categorySort_ratingScoreDescending,
      appStrings(context).categorySort_ratingScoreAscending,
      appStrings(context).categorySort_visitsDescending,
      appStrings(context).categorySort_visitsAscending,
      appStrings(context).categorySort_random,
      appStrings(context).categorySort_manual,
    ];

    final sortOptionsList = sortOptions.map((option) {
      return PopupMenuItem(
        value: option,
        child: Text(option),
      );
    }).toList();

    return PopupMenuButton(
      icon: Icon(Icons.sort),
      onSelected: (value) {
        _onMenuItemSelected(value as int, context);
      },
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0))
      ),
      // padding: EdgeInsets.zero,
      // offset: Offset(0, 50),
      color: Theme.of(context).primaryColor,
      itemBuilder: (ctx) => sortOptionsList,
    );
  }
  //
  // PopupMenuItem _buildPopupMenuItem(
  //     String title, int position, {IconData iconData, BuildContext context}) {
  //   return PopupMenuItem(
  //     value: position,
  //     child:  Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //       children: [
  //         Text(title, style: Theme.of(context).textTheme.bodyText1),
  //       ],
  //     ),
  //   );
  // }

  _onMenuItemSelected(int value, BuildContext context) {
    // MaterialPageRoute route;
    //
    // if (value == SortMenuOptions.favorites.index) {
    //   route = MaterialPageRoute(builder: (context) => FavoritesViewPage(
    //     isAdmin: isAdmin,
    //   ));
    // } else if (value == SortMenuOptions.tags.index) {
    //   showChooseTagSheet(context);
    // } else if (value == SortMenuOptions.recent.index) {
    //   route = MaterialPageRoute(builder: (context) => SortedViewPage(
    //       isAdmin: isAdmin, sorting: new SortModel(albumSort: 4), // Addition Date, New > Old
    //       title: appStrings(context).categoryDiscoverRecent_title
    //   ));
    // } else if (value == SortMenuOptions.top_rated.index) {
    //   route = MaterialPageRoute(builder: (context) => SortedViewPage(
    //       isAdmin: isAdmin, sorting: new SortModel(albumSort: 8), // Rate, High > Low
    //       title: appStrings(context).categoryDiscoverBest_title
    //   ));
    // } else if (value == SortMenuOptions.top_viewed.index) {
    //   route = MaterialPageRoute(builder: (context) => SortedViewPage(
    //       isAdmin: isAdmin, sorting: new SortModel(albumSort: 10), // Views, High > Low
    //       title: appStrings(context).categoryDiscoverVisits_title
    //   ));
    // }
    // if (route != null) Navigator.of(context).push(route);
  }
}

