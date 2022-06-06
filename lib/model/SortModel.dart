import 'package:piwigo_ng/constants/SettingsConstants.dart';

class SortModel {
  static const String ASC = "ASC";
  static const String DESC = "DESC";
  String _sorting;
  String _sortingTitle = Constants.albumSort[4];

  SortModel({int albumSort}) {
    if (albumSort != null) {
      _sorting = parseAlbumSort(albumSort);
      _sortingTitle = Constants.albumSort[albumSort];
    }
  }

  String parseSortOption(int sortOption) {
    switch (sortOption) {
      case 0:
        return "file";
      case 1:
        return "name";
      case 2:
        return "rating_score";
      case 3:
        return "date_creation";
      case 4:
        return "date_available";
      case 5:
        return "hit";
      case 6:
        return "id";
      case 7:
        return "random";
      default:
        return "";
    }
  }

  String parseAlbumSort(int albumSort) {
    switch (albumSort) {
      case 0:
        return "name " + ASC;
      case 1:
        return "name " + DESC;
      case 2:
        return "date_creation " + DESC;
      case 3:
        return "date_creation " + ASC;
      case 4:
        return "date_available " + DESC;
      case 5:
        return "date_available " + ASC;
      case 6:
        return "file " + ASC;
      case 7:
        return "file " + DESC;
      case 8:
        return "rating_score " + DESC;
      case 9:
        return "rating_score " + ASC;
      case 10:
        return "hit " + DESC;
      case 11:
        return "hit " + ASC;
      case 12:
        return "";
      case 13:
        return "random";
      default:
        return "date_available " + DESC;
    }
  }

  addSortCondition(int sortOption, String sortOrder) {
    if (_sorting.isEmpty) {
      _sorting = parseSortOption(sortOption) + " " + sortOrder;
    } else {
      _sorting += ", " + parseSortOption(sortOption) + " " + sortOrder;
    }
    return _sorting;
  }

  String get sortOrder => _sorting;
  String get sortTitle => _sortingTitle;
}