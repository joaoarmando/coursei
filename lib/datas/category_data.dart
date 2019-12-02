class CategoryData {
  String categoryName;
  int categoryId;
  bool isDefault;

  CategoryData.fromJSON(Map<String,dynamic> category){
    categoryName = category["categoryName"];
    categoryId = category["categoryId"];
    isDefault = category["isDefault"];
  }
}