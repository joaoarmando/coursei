import 'package:coursei/appColors.dart';
import 'package:coursei/datas/category_data.dart';
import 'package:coursei/screens/categories_screen.dart';
import 'package:coursei/screens/explore_category_screen.dart';
import 'package:flutter/material.dart';

import '../utils.dart';

class CategoryChip extends StatelessWidget {
  final List<CategoryData> categories;
  final selectedIndex;
  CategoryChip({@required this.categories,this.selectedIndex});
  
  @override
  Widget build(BuildContext context) {
    CategoryData category = categories[selectedIndex];
    return Container(
        constraints: BoxConstraints(
          minWidth: 120
        ),
        margin: const EdgeInsets.only(left: 12,bottom: 5,top: 5),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            width: 1,
            color: secondaryColor
          ),
          boxShadow: [
           BoxShadow(color: Colors.transparent)
          ]
        ),
        child: Container(
          constraints: BoxConstraints(
            minWidth: 120,
            minHeight: 50
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              splashColor: secondarySplashColor,
              borderRadius: BorderRadius.circular(999),
              onTap: (){
                
                final page =  CategoriesScreen(categories,category);
                Navigator.push(context, MaterialPageRoute(builder: (context) => page, settings: RouteSettings(name: "CategoriesScreen")));
                sendClickCategory(category);
                  //navigateToCategories(category, context);
              },
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal:12),
                child: Text(category.categoryName,
                  style: TextStyle(
                    color: secondaryColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
  }
  navigateToCategories(CategoryData category, BuildContext context){
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExploreCategoryScreen(category)
      )
    );
  }
}