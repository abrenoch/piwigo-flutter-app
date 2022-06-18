import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:piwigo_ng/api/SessionAPI.dart';
import 'package:piwigo_ng/constants/SettingsConstants.dart';
import 'package:piwigo_ng/model/SortModel.dart';
import 'package:piwigo_ng/views/FavoritesViewPage.dart';
import 'package:piwigo_ng/views/SortedViewPage.dart';
import 'package:piwigo_ng/views/components/dialogs/dialogs.dart';

enum ViewPopupMenuOptions {
  favorites, tags, top_viewed, top_rated, recent, user_collections
}

class ViewPopupMenuButton extends StatefulWidget {
  ViewPopupMenuButton({Key key, this.isAdmin}) : super(key: key);
  final bool isAdmin;

  @override
  _ViewPopupMenuButton createState() => _ViewPopupMenuButton();
}
class _ViewPopupMenuButton extends State<ViewPopupMenuButton> {

  bool _hasUserCollections = false;

  checkMethods() async {
    bool hasUserCollections = await methodExists("pwg.collections.getList");
    setState(() {
      _hasUserCollections = hasUserCollections;
    });
  }

  @override
  void initState() {
    super.initState();
    checkMethods();
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      onSelected: (value) {
        _onMenuItemSelected(value as int, context);
      },
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0))
      ),
      // padding: EdgeInsets.zero,
      // offset: Offset(0, 50),
      color: Theme.of(context).primaryColor,
      itemBuilder: (ctx) => [
         widget.isAdmin ? _buildPopupMenuItem(
          appStrings(context).categoryDiscoverFavorites_title, ViewPopupMenuOptions.favorites.index,
          context: context,
          iconData: Icons.favorite_border
        ) : null,
        _buildPopupMenuItem(
          appStrings(context).tags, ViewPopupMenuOptions.tags.index,
          context: context,
          iconData: Icons.local_offer_outlined
        ),
        _buildPopupMenuItem(
          appStrings(context).categoryDiscoverVisits_title, ViewPopupMenuOptions.top_viewed.index,
          context: context,
        ),
        _buildPopupMenuItem(
          appStrings(context).categoryDiscoverBest_title, ViewPopupMenuOptions.top_rated.index,
          context: context,
        ),
        _buildPopupMenuItem(
          appStrings(context).categoryDiscoverRecent_title, ViewPopupMenuOptions.recent.index,
          context: context,
          iconData: Icons.access_time_rounded
        ),
        _hasUserCollections ? _buildPopupMenuItem(
            "User Collections", ViewPopupMenuOptions.user_collections.index,
            context: context,
            iconData: Icons.collections_bookmark_rounded
        ) : null,
      ],
    );
  }

  PopupMenuItem _buildPopupMenuItem(
      String title, int position, {IconData iconData, BuildContext context}) {
    return PopupMenuItem(
      value: position,
      child:  Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: Theme.of(context).textTheme.bodyText1),
          Spacer(),
          if (iconData != null) Icon(iconData, color: Theme.of(context).iconTheme.color),
        ],
      ),
    );
  }

  _onMenuItemSelected(int value, BuildContext context) {
    MaterialPageRoute route;

    if (value == ViewPopupMenuOptions.favorites.index) {
      route = MaterialPageRoute(builder: (context) => FavoritesViewPage(
        isAdmin: widget.isAdmin,
      ));
    } else if (value == ViewPopupMenuOptions.tags.index) {
      showChooseTagSheet(context);
    } else if (value == ViewPopupMenuOptions.recent.index) {
      route = MaterialPageRoute(builder: (context) => SortedViewPage(
        isAdmin: widget.isAdmin, sorting: new SortModel(albumSort: 4), // Addition Date, New > Old
        title: appStrings(context).categoryDiscoverRecent_title
      ));
    } else if (value == ViewPopupMenuOptions.top_rated.index) {
      route = MaterialPageRoute(builder: (context) => SortedViewPage(
        isAdmin: widget.isAdmin, sorting: new SortModel(albumSort: 8), // Rate, High > Low
        title: appStrings(context).categoryDiscoverBest_title
      ));
    } else if (value == ViewPopupMenuOptions.top_viewed.index) {
      route = MaterialPageRoute(builder: (context) => SortedViewPage(
        isAdmin: widget.isAdmin, sorting: new SortModel(albumSort: 10), // Views, High > Low
        title: appStrings(context).categoryDiscoverVisits_title
      ));
    }
    if (route != null) Navigator.of(context).push(route);
  }
}

