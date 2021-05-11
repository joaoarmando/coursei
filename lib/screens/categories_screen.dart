import 'package:coursei/appColors.dart';
import 'package:coursei/datas/category_data.dart';
import 'package:coursei/widgets/appbar_button.dart';
import 'package:coursei/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';

import 'explore_category_screen.dart';

class CategoriesScreen extends StatefulWidget {
  final List<CategoryData> categories;
  final categorySelected;
  CategoriesScreen(this.categories,this.categorySelected);
  @override
  _CategoriesScreen createState() => _CategoriesScreen();
}

class _CategoriesScreen extends State<CategoriesScreen>  {
 bool ignoreDelay = true;


  @override
  void initState() {
    super.initState();
    if(widget.categorySelected != null){
      ignoreDelay = false;
      Future.delayed(Duration(milliseconds: 1)).then((a) async{
          await navigateToCategories(widget.categorySelected);
          Navigator.pop(context);
          //ignoreDelay = true;
      });
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: <Widget>[
            buildAppBar(context),

            Expanded(
              child: !ignoreDelay ? FutureBuilder(
                future: Future.delayed(Duration(milliseconds: 3000 )),
                builder: (context,snapshot){

                  if (snapshot.connectionState == ConnectionState.done)
                     return buildListCategories();
                  else 
                    return Container();  

                },
              ) : buildListCategories(),
            ),

          ],
        ),
      ),
    );
  }

  Widget buildListCategories(){
    return ListView.builder(
      itemCount: widget.categories.length,
      itemBuilder: (context,index){
        return buildFastActions(context, widget.categories[index]);
      },
    );
  }



  Widget buildAppBar(BuildContext context){
    return CustomAppBar(
      child: Row(
        children: <Widget>[
          AppBarButton(
            icon: Icons.close,
            backgroundColor: greyBackground,
            function: (){
              Navigator.pop(context);
            },
          ),
          SizedBox(width: 12),
          Text("Todas as categorias",
            style: TextStyle(
              color: primaryText,
              fontWeight: FontWeight.w700,
              fontSize: 21
            ),
          )
        ],
      ),
    );
  }

  Widget buildFastActions(BuildContext context, CategoryData category){
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: () => navigateToCategories(category),
        child: Container(
          height: 55,
          alignment: Alignment.centerLeft,
          margin: EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(width: 1,color: Color(0xffD3E0E1))
            )
          ),
          width: MediaQuery.of(context).size.width,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(category.categoryName,
                style: TextStyle(
                  color: secondaryText,
                  fontSize: 14
                ),
                textAlign: TextAlign.start,
              ),
              Icon(Icons.arrow_right, color: Color(0xffD3E0E1),size: 25),
            ],
          ),
        ),
      ),
    );
  }

  navigateToCategories(CategoryData category) async{
    return await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (c, a1, a2) => ExploreCategoryScreen(category),
        transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child),
        transitionDuration: Duration(milliseconds: 200),
      ),
    );
  }
 
 
  
}