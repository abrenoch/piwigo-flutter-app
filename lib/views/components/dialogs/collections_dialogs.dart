import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:piwigo_ng/api/PluginsAPI.dart';
import 'package:piwigo_ng/constants/SettingsConstants.dart';
import 'package:piwigo_ng/views/CollectionsViewPage.dart';

showChooseCollectionSheet(context, {content = ''}) {
  showModalBottomSheet<int>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return DraggableScrollableSheet(
          key: UniqueKey(),
          initialChildSize: 0.93,
          maxChildSize: 0.93,
          minChildSize: .5,
          expand: false,
          builder: (context, controller) => Column(
            children: [
              Container(
                height: 55,
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      appStrings(context).alertDismissButton,
                      style: Theme.of(context).textTheme.headline4,
                    ),
                  )
                ),
              ),
              Expanded(
                child: Ink(
                  color: Theme.of(context).primaryColor,
                  child: ListView(
                    controller: controller,
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    children: [
                      SizedBox(height: 18),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Text("User Collections",
                            style: Theme.of(context).textTheme.headline1
                        ),
                      ),
                      SizedBox(height: 10),
                      FutureBuilder<Map<String,dynamic>>(
                        future: fetchCollections(),
                        builder: (BuildContext context, AsyncSnapshot collectionsSnapshot) {
                          if(collectionsSnapshot.hasData){
                            if(collectionsSnapshot.data['stat'] == 'fail') {
                              return Container(
                                padding: EdgeInsets.all(10),
                                child: Text(collectionsSnapshot.data['result']),
                              ); //appStrings(context).categoryMainEmtpy
                            }
                            var collections = collectionsSnapshot.data['result']['collections'];
                            collections.removeWhere((collection) => (
                                collection["nb_images"] == "0"
                            ));
                            return Wrap(
                                direction: Axis.horizontal,
                                children: <Widget>[
                                ListView.separated(
                                    scrollDirection: Axis.vertical,
                                    shrinkWrap: true,
                                    physics: ClampingScrollPhysics(),
                                    clipBehavior: Clip.hardEdge,
                                    padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                                    // itemExtent: 40.0,
                                    separatorBuilder: (BuildContext context, int index) {
                                      return Divider(height: 1, color: Theme.of(context).primaryColor);
                                    },
                                    itemCount: collections.length,
                                    itemBuilder: (context, index) {
                                      var collection = collections[index];
                                      var borderRadius = BorderRadius.circular(0);
                                      var radius = Radius.circular(10);

                                      if(index == collections.length - 1) {
                                        borderRadius = BorderRadius.only(
                                          bottomLeft: radius,
                                          bottomRight: radius,
                                        );
                                      } else if (index == 0) {
                                        borderRadius = BorderRadius.only(
                                          topLeft: radius,
                                          topRight: radius,
                                        );
                                      }

                                      int nbImages = int.parse(collection['nb_images']);
                                      return ListTile(
                                        shape: RoundedRectangleBorder(
                                            borderRadius: borderRadius
                                        ),
                                        title: Text(
                                            collection['name'] + ' (${ appStrings(context).imageCount(nbImages) })',
                                          style: Theme.of(context).textTheme.bodyText1
                                        ),
                                        // title: Text(tag['name'], style: Theme.of(context).textTheme.bodyText1),
                                        tileColor: Theme.of(context).backgroundColor,
                                        contentPadding: EdgeInsets.symmetric(horizontal: 15),
                                        dense: true,
                                        onTap: () => {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(builder: (context) => CollectionsViewPage(
                                              isAdmin: true,
                                              collection: collection['id'].toString(),
                                              title: collection['name'],
                                              nbImages: nbImages,
                                            ))
                                          )
                                        }
                                      );
                                    },
                                  ),
                                  Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                        "${collections.length} Collections",
                                        style: Theme.of(context).textTheme.subtitle2
                                    ),
                                  ),
                                ]
                            );
                          } else {
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                        }
                      ),
                      SizedBox(height: 10)
                    ],
                  ),
                )
              ),
            ],
          ),
      );
    },
  );
}
