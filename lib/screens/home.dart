import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:coursei/appColors.dart';
import 'package:coursei/appColors.dart' as prefix0;
import 'package:coursei/blocs/courses_bloc.dart';
import 'package:coursei/blocs/home_bloc.dart';
import 'package:coursei/blocs/login_bloc.dart';
import 'package:coursei/blocs/user_bloc.dart';
import 'package:coursei/datas/category_data.dart';
import 'package:coursei/screens/add_course_screen.dart';
import 'package:coursei/screens/new_account_screen.dart';
import 'package:coursei/screens/saved_screen.dart';
import 'package:coursei/screens/search_course_screen.dart';
import 'package:coursei/utils.dart';
import 'package:coursei/widgets/category_chips.dart';
import 'package:coursei/widgets/custom_appbar.dart';
import 'package:coursei/widgets/course_list.dart';
import 'package:coursei/widgets/login_dialog.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart' show timeDilation;

import 'categories_screen.dart';


class Home extends StatefulWidget {
  final FirebaseAnalyticsObserver observer;
  Home(this.observer);
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  AnimationController _categoriesAnimationController;
  Animation _offsetFloatCategories; 
  double currentFabPosition = 0;
  final _userBloc = BlocProvider.getBloc<UserBloc>();
  final _homeBloc = BlocProvider.getBloc<HomeBloc>();
  final _coursesBloc = BlocProvider.getBloc<CoursesBloc>();
  bool firstLoadComplete = true;
  Future<bool> getInternetConnection;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  initState() {
    super.initState();
    _coursesBloc.getSavedCourses();
    getInternetConnection = hasInternetConnection(true);
    

    _categoriesAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _offsetFloatCategories = Tween<Offset>(begin: Offset(0.1, 0.0), end: Offset.zero)
        .animate(_categoriesAnimationController);
        
    
  }

  @override
  void dispose() { 
    _categoriesAnimationController.dispose();
    super.dispose();
  }

  void setCurrentScreen(){
     widget.observer.analytics.setCurrentScreen(
      screenName: 'HomeScreen',
    );
  }
  @override
  Widget build(BuildContext context) {
    setCurrentScreen();
  
    return Theme(
      data: Theme.of(context).copyWith(
        primaryColor: secondaryColor,
        cursorColor: secondaryColor,
       ),
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: backgroundColor,
        body: SafeArea(
          bottom: false,
          child: NestedScrollView(
            headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      appBarHome(),
                      Row(
                        children: <Widget>[
                          searchBar(context),
                          preloadFlareAssets(),
                        ],
                      ),
                    ]
                  ),
                ),
                SliverPersistentHeader(
                  delegate: _SliverAppBarDelegate(
                    PreferredSize(
                      preferredSize: Size(MediaQuery.of(context).size.width, 92),
                      child: categoryList(context),
                    )
                  ),
                  pinned: true,
                ),
              ];
            },
            body: coursesList(context),
          ),
        ),
        floatingActionButton: fabAddCourse(context),
      ),
    );
  }

  Widget appBarHome(){    
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text("Coursei",
                style: TextStyle(color: primaryText,fontSize: 25, fontWeight: FontWeight.w700),
              ),
              Text("Descubra cursos gratuitos!",
                style: TextStyle(color: tertiaryText,fontSize: 20, fontWeight: FontWeight.w700),
              ),

            ],
          ),
          InkWell(
            borderRadius: BorderRadius.circular(999),
            splashColor: primarySplashColor,
            onTap: () async{
              bool hasInternet = await hasInternetConnection(false);
              if (hasInternet){
                  if (_userBloc.verifySignIn()){
                    //vai pra tela de cursos salvos
                    await Future.delayed(Duration(milliseconds: 150));
                    Navigator.push(context, MaterialPageRoute(builder: (context) => SavedCoursesScreen(),settings: RouteSettings(name: "SavedCoursesScreen")));
                    _coursesBloc.clearNotificationBadge();
                  }
                  else{
                    //mostra dialog  
                    await showDialogSignUp();
                    _userBloc.backToDefaultDialog();
                  }
              }
              else showSnackbarNoInternet();
              
                
            },
            child: Stack(
              children: <Widget>[
                Container(
                  height: 45,
                  width: 45,
                  padding: const EdgeInsets.all(5) , // borde width
                  decoration: new BoxDecoration(// border color
                    shape: BoxShape.circle,
                    border: Border.all(color: _userBloc.verifySignIn() ? secondaryColor : Colors.transparent,width:2),
                    color: _userBloc.verifySignIn() ? Colors.transparent : greyBackground
                  ),
                  child: _userBloc.verifySignIn() ? CircleAvatar(
                      child: Image.asset("assets/icons/ic_user_male.png"),
                      backgroundColor: Colors.transparent
                    ) : ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: Icon(Icons.person,color: tertiaryText,size: 30),
                 
                    )
                ),
                StreamBuilder<int>(
                  stream: _coursesBloc.outSavedCourses,
                  initialData: _coursesBloc.getSavedCoursesCount(),
                  builder: (context, snapshot) {

                    if (snapshot.data == 0 || snapshot.data == null || !_userBloc.verifySignIn()) return Container();

                    else return Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        height: 20,
                        width: 20,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: secondaryColor
                        ),
                        child: Text("${snapshot.data}",
                          style: TextStyle(
                            color: secondaryText,
                            fontSize: 12,
                            fontWeight: FontWeight.w600
                          ),
                          textAlign: TextAlign.center,
                         
                        ),
                      ),
                    );
                  }
                )
              ],
            ),
          ),


        ],
      ),
    );
  }
  Widget searchBar(BuildContext context){
    return InkWell(
      onTap: (){
        final page =  SearchCourseScreen();
        Navigator.push(context, MaterialPageRoute(builder: (context) => page, settings: RouteSettings(name: "SearchCourseScreen")));
      },
      child: Hero(
        tag: "_backgroundsearch",
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.centerLeft,
          width: MediaQuery.of(context).size.width * .8,
          height: 50,
          decoration: BoxDecoration(
            color: greyBackground,
            borderRadius: BorderRadius.circular(10)
          ),
          child: IgnorePointer(
            ignoring: true,
            child: Material(
              type: MaterialType.transparency,
              child: TextField(
                decoration: InputDecoration(
                  suffixIcon: Icon(Icons.search,size: 30),
                  border: InputBorder.none,
                  hintText: "O que quer aprender?",
                  hintStyle: TextStyle(color: hintColor, fontSize: 20)
                ),
                style: TextStyle(color: primaryText, fontSize: 20, fontWeight: FontWeight.w600),   
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget categoryList(BuildContext context) {
    return StreamBuilder<List<CategoryData>>(
        stream: _homeBloc.outCategories,
        builder: (context, snapshot) {
          if (snapshot.data != null)
            return CustomAppBar(
              ignorePadding: true,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text("Categorias",
                          style: TextStyle(color: primaryText,fontSize: 20, fontWeight: FontWeight.w600),
                        ),
                        InkWell(
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context) => CategoriesScreen(snapshot.data,null),
                              settings: RouteSettings(name: "CourseDetailsScreen")
                              )
                            );
                          },
                          child: Text("Ver tudo",
                            style: TextStyle(color: secondaryColor,fontSize: 18, fontWeight: FontWeight.w700),
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                    height: 50,
                    color: Colors.transparent,
                    child: StreamBuilder<List<CategoryData>>(
                      stream: _homeBloc.outCategories,
                      builder: (context, snapshot) {
                        if (snapshot.data == null) return Container();
                        _categoriesAnimationController.forward();
                        return SlideTransition(
                          position: _offsetFloatCategories,
                          child: ListView.builder(
                            itemCount: snapshot.data.length >= 4 ? 4 : snapshot.data.length,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context,index){
                              return CategoryChip(
                                categories: snapshot.data,
                                selectedIndex:  index,
                              );
                            },
                          ),
                        );
                      }
                    ),
                  )
                ],
              ) 
            );
          else  return Container();    
            
        }
      );
  }

  Widget coursesList(BuildContext context){
    _homeBloc.getCourses(-1,false);
    return CourseList(
      outCourseListRefresh: _homeBloc.outCourseListRefresh,
      retryLoad: _homeBloc.retryLoad,
      outCourses: _homeBloc.outCourses,
      nextPage: _homeBloc.nextPage,
      tryAgainNextPage: _homeBloc.tryAgainNextPage,
    );
    /*return StreamBuilder<LoadingCoursesState>(
      stream: _homeBloc.outCourseListRefresh,
      initialData: LoadingCoursesState.IDLE,
      builder: (context, snapshot) {
        if (snapshot.data == LoadingCoursesState.NO_INTERNET_CONNECTION){

          return NoInternet(_homeBloc.retryLoad);
          
        }
        else if (snapshot.data == LoadingCoursesState.LOADING)
          return Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(secondaryColor),strokeWidth: 2));
        else   
          return StreamBuilder<Map<String,dynamic>>(
            stream: _homeBloc.outCourses,
            builder: (context, snapshot) {
              
              if (snapshot.data == null) return Container();
              var itemCount = snapshot.data["courses"].length + 1;
                if (snapshot.data["canAnimate"]) _controller.forward();

                return Opacity(
                  opacity: opacityTween.value,
                  child: SlideTransition(
                    position: _offsetFloat,
                    child:  ListView.builder(
                    itemCount: itemCount,
                    shrinkWrap: true,
                    itemBuilder: (context,index){
                      if (index < snapshot.data["courses"].length){
                        return CourseTile(
                          course: snapshot.data["courses"][index],
                        );
                      }
                      else if (snapshot.data["hasMore"]){
                        return FutureBuilder(
                          future: hasInternetConnection(true),
                          builder: (context, snapshot) {

                            bool isLoading = snapshot.connectionState == ConnectionState.waiting;
                            if (!isLoading && snapshot.data != null) isLoading = snapshot.data;
                            if (isLoading){
                              //tem net
                              if (snapshot.connectionState == ConnectionState.done) _homeBloc.nextPage();
                              return Container(
                                width: 40,
                                height: 40,
                                margin: EdgeInsets.symmetric(vertical: 12,horizontal: 0),
                                alignment: Alignment.center,
                                child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(secondaryColor), strokeWidth: 2),
                              );
                            }
                            else {
                              // na tem internet
                              return CourseTileNoInternet((){
                                _homeBloc.tryAgainNextPage();
                              });
                            }
                          },
                        );
                        
                      }
                      else return Container();
                    },
                  ),
              ),
                ); 

            }
          );
      }
    ); */
    

  }
  Widget fabAddCourse(BuildContext context){
    return Material(
      shadowColor: Colors.grey[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(99)
      ),
      elevation: 6.0,
      child: Container(
        height: 55,
        width: 55,
        decoration: BoxDecoration(
          color: secondaryColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
                color: secondaryColor.withOpacity(.4),
                offset: Offset(0.0, 5.0),
                blurRadius: 10.0)
          ]),
        child: Material(
          type: MaterialType.transparency,
          elevation: 6.0,
          color: Colors.transparent,
          child: InkWell(
            splashColor: secondarySplashColor,
            borderRadius: BorderRadius.circular(99),
            onTap: (){

              final page = AddCourseScreen();
              Navigator.push(context, MaterialPageRoute(builder: (context) => page,settings: RouteSettings(name: "AddCourseScreen")));
              
            },
            child: Icon(Icons.add, size: 35.0, color: secondaryText),
          ),
        ),
      ),
    );
  }
  showDialogSignUp() async{
    return await showDialog<void>(
    context: context,
    barrierDismissible: true, // user must tap button!
    builder: (BuildContext context) {
        final _loginBloc = LoginBloc();
      _loginBloc.setUserBloc(_userBloc);
      return AlertDialog(
        contentPadding: EdgeInsets.fromLTRB(12,12,12,12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20)
        ) ,
        content: Theme(
          data: Theme.of(context).copyWith(
            primaryColor: secondaryColor,
            cursorColor: secondaryColor,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width * .8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,

                ),
                child: StreamBuilder<DialogState>(
                  stream: _userBloc.outDialogState,
                  initialData: DialogState.DIALOG_OPTIONS,
                  builder: (context, snapshot) {
                    switch(snapshot.data){
                      case DialogState.DIALOG_OPTIONS:
                        return buildDialogLoginOptions();
                      break;
                      case DialogState.LOGIN_STATE:
                        return LoginDialog();
                      break;  
                      default:
                      return Container();
                    }
                  }
                ),
              ),
            ],
          ),
        ),
        
      );
    },
  ); 
  }
  void showSnackbarNoInternet(){
      _scaffoldKey.currentState.showSnackBar(
          SnackBar(content: Text("Sem conexão com a internet",
          textAlign: TextAlign.left, style: TextStyle(fontSize: 16.0, fontWeight: 
          FontWeight.bold),), duration: Duration(seconds: 2), backgroundColor: Colors.red,)
      );
  }
  Widget _buildDialogButton({@required isPrimaryButton, String text, Function function}){
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Material(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)
              ),
            elevation: 0.0,
            child: Container(
              height: 55,
              width: MediaQuery.of(context).size.width * .7,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: isPrimaryButton ? secondaryColor : backgroundColor,
                border: Border.all(color: secondaryColor, width: 1)
              ),
              child: Material(
                type: MaterialType.transparency,
                elevation: 0.0,
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  splashColor: secondarySplashColor,
                  onTap: function,
                  child:  Center(
                    child: Text(text,
                      style: TextStyle(
                        color: isPrimaryButton ? primaryText : secondaryColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w700
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
          ),
    ),
        ],
      );
  }
 
  Widget buildDialogLoginOptions(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          "Fazer login",
          style: TextStyle(color: primaryText, fontSize: 21,fontWeight: FontWeight.w700),
          textAlign: TextAlign.left,
        ),
        SizedBox(height: 15),
        Text("Você precisa fazer login para ver seus cursos salvos",
          style: TextStyle(color: secondaryText, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 15),
        _buildDialogButton(
          isPrimaryButton:true,
          text:"Já tenho uma conta",
          function: _userBloc.goToSignIn,
        ),
        SizedBox(height: 15),
        _buildDialogButton(
          isPrimaryButton:false,
          text:"Criar uma conta",
          function: () async{
             await Future.delayed(Duration(milliseconds: 150));
             Navigator.pop(context);
             Navigator.push(context, MaterialPageRoute(builder: (context) => NewAccountScreen(),settings: RouteSettings(name: "NewAccountScreen")));

          }
        ),
        
    
      ],
    );
  }

  Widget preloadFlareAssets(){
    return Container(
      width: 0,
      height: 0,
      child: Stack(
        children: <Widget>[
          FlareActor("assets/check_animation.flr"),
          FlareActor("assets/error.flr"),
          FlareActor("assets/waiting.flr"),
        ],
      ),
    );
  }
  Widget buildSignUpButton(){
   return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: <Widget>[
      AnimatedContainer(
        width: MediaQuery.of(context).size.width * .5,
        height: 50,
        duration: Duration(milliseconds: 300),
        child: Material(
          shadowColor: Colors.grey[50],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999)
            ),
          elevation: 6.0,
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: secondaryColor
            ),
            child: Material(
              type: MaterialType.transparency,
              elevation: 6.0,
              color: Colors.transparent,
              shadowColor: Colors.grey[50],
              child: InkWell(
                borderRadius: BorderRadius.circular(999),
                splashColor: secondarySplashColor,
                onTap: (){
                  _homeBloc.getCategories();
                  _homeBloc.getCourses(-1, false);
                } ,
                child: Center(
                  child: Text(
                    "Tentar novamente",
                    style: TextStyle(
                      color: secondaryText,
                      fontSize: 18,
                      fontWeight: FontWeight.w600
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
        ),
    ),
      ),
    ],
  );
  }

  Widget buildCourseTileInternetError(){
   return Column(
     children: <Widget>[
      Text("Sem conexão com a internet",
        style: TextStyle(
          color: prefix0.secondaryText,
          fontWeight: FontWeight.w600,
          fontSize: 14
        ),
      ),
      SizedBox(height: 12),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          AnimatedContainer(
            width: MediaQuery.of(context).size.width * .5,
            height: 45,
            duration: Duration(milliseconds: 300),
            child: Material(
              shadowColor: Colors.grey[50],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999)
                ),
              elevation: 6.0,
              child: Container(
                height: 45,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: secondaryColor
                ),
                child: Material(
                  type: MaterialType.transparency,
                  elevation: 6.0,
                  color: Colors.transparent,
                  shadowColor: Colors.grey[50],
                  child: InkWell(
                    borderRadius: BorderRadius.circular(999),
                    splashColor: secondarySplashColor,
                    onTap: (){
                       _homeBloc.nextPage();
                    } ,
                    child: Center(
                      child: Text(
                        "Tentar novamente",
                        style: TextStyle(
                          color: secondaryText,
                          fontSize: 18,
                          fontWeight: FontWeight.w600
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      SizedBox(height: 20),
    ],
  );

  }


}



class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final PreferredSize _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
        return Container(
          color: backgroundColor,
          child: _tabBar,
        );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}