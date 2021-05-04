import 'package:coursei/appColors.dart' as prefix0;
import 'package:coursei/widgets/appbar_button.dart';
import 'package:coursei/widgets/custom_appbar.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

class ReportProblemScreen extends StatefulWidget {
  final String courseObjectId;
  ReportProblemScreen(this.courseObjectId);
  @override
  _ReportProblemScreenState createState() => _ReportProblemScreenState();
}

class _ReportProblemScreenState extends State<ReportProblemScreen> {
  String groupValue;
  var focusNode = new FocusNode();
  bool enabledToSend = false;
  bool showingRadioGroup = true;
  bool isLoading = false;
  String messageReport;
  final myController = TextEditingController();
  List<String> comumProblems = [
    "O link não funciona",
    "Este curso não é gratuito",
    "Os dados do curso estão incorretos",
    "Outros"
  ];
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool ignoreTimer = false;
  bool screnClosed = false;
  bool bottomSheetIsOpen = false;



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: <Widget>[
            buildAppBar(context),
            SizedBox(height:24),
             AnimatedSwitcher(
              duration: Duration(milliseconds: 600),
              child: buildListOptions(),
            ),
           
           Expanded(
              child: Align(
                alignment: Alignment.bottomRight,
                child: buildBtReportProblem(),
              ),
            ) 

          ],
        ),
      ),
    );
  }

  Widget buildListOptions(){
    if (showingRadioGroup){
      return Column(
        children: comumProblems.map<Widget>((c) => buildFastActions(context, c,c)).toList(),
      );
    }
    else return buildMessage();
    
    
  }
  Widget buildMessage(){
    return Container(
      height: 168,
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.all(12),
      padding: EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: prefix0.greyBackground,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Form(
        key: formKey,
        child: TextFormField(
          focusNode: focusNode,
          controller:myController,
          style: TextStyle(
            color: prefix0.primaryText,
            fontSize: 18,
          ),
          maxLines: 5,
          maxLength: 300,
          onChanged: (s){
            formKey.currentState.validate();
          },
          validator: (s){
            if (s.length >= 10){
              if (!enabledToSend){
                setState(() {
                   enabledToSend = true;
                });
              }
               return '';
            }
            else {
              if (enabledToSend){
                setState(() {
                   enabledToSend = false;
                });
              }
              return 'Digite ao menos 10 caracteres';
            }
            
          },
          decoration: InputDecoration(
            hintText: "Qual o problema com este curso?",
            border: InputBorder.none,
            hintStyle: TextStyle(
              color: prefix0.hintColor,
              fontSize: 18,
            )
          ),
        ),
      ),
    );
  }

  Widget buildAppBar(BuildContext context){
    return CustomAppBar(
      child: Row(
        children: <Widget>[
          AppBarButton(
            icon: Icons.close,
            backgroundColor: prefix0.greyBackground,
            function: (){
              Navigator.pop(context);
            },
          ),
          SizedBox(width: 12),
          Text("Relatar um problema",
            style: TextStyle(
              color: prefix0.primaryText,
              fontWeight: FontWeight.w700,
              fontSize: 21
            ),
          )
        ],
      ),
    );
  }

  Widget buildFastActions(BuildContext context, String actionName, String value){
    return Material(
      child: InkWell(
        onTap: (){
           selectRadio(value);
        },
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
              Text(actionName,
                style: TextStyle(
                  color: prefix0.secondaryText,
                  fontSize: 14
                ),
                textAlign: TextAlign.start,
              ),
              value != null ? Radio(
                onChanged: selectRadio,
                activeColor: prefix0.secondaryColor,
                value: value,
                groupValue: groupValue,

              ) : Icon(Icons.arrow_left, color: Color(0xffD3E0E1),size: 25),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget buildBtReportProblem(){
    return Container(
      height: 55,
      child: Material(
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(999))
          ),
        elevation: 6.0,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          height: 55,
          width: !isLoading ? MediaQuery.of(context).size.width * .55 : 100,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(999)),
            color: enabledToSend ? prefix0.secondaryColor : Colors.grey,
            boxShadow:[
              BoxShadow(
                color: enabledToSend ? prefix0.secondaryColor.withOpacity(.4) : Colors.transparent,
                offset: Offset(5, 0),
                blurRadius: 10.0)
            ]
          ),
          child: Material(
            type: MaterialType.transparency,
            elevation: 6.0,
            color: Colors.transparent,
            child: InkWell(
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(999)),
              splashColor: prefix0.secondarySplashColor,
              onTap: enabledToSend && !isLoading ? (){

                if (groupValue != null)  reportProblem(groupValue); 
                else  reportProblem(myController.text); 

              } : null,
              child: !isLoading ? Container(
                  alignment: Alignment.center,
                  child: Text("Enviar",
                    style: TextStyle(
                      color: prefix0.secondaryText,
                      fontSize: 18,
                      fontWeight: FontWeight.w700
                    ),
                  ),
              ) : Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(prefix0.secondaryText),strokeWidth: 2,)),
            ),
          ),
      ),
    ),
  );
  }
  void selectRadio(value) {
    this.setState(() {

      if (value == "Outros") {
        showingRadioGroup = false;
        enabledToSend = false;
        groupValue = null;
        Future.delayed(Duration(milliseconds: 600)).then((a){
          FocusScope.of(context).requestFocus(focusNode);
        });
      }
      else {
        groupValue = value;
        enabledToSend = true;
      }
    
    });
  }

  void reportProblem(String message) async{

    setState(() { isLoading = true; });
    ParseResponse course =  await ParseObject("Courses").getObject(widget.courseObjectId); 
    if (course.success){
        ParseACL parseACL = ParseACL();
        parseACL.setPublicReadAccess(allowed: false);
        parseACL.setPublicWriteAccess(allowed: false);
        var reportCourse = ParseObject('Reports')
        ..set('message', message)
        ..set('course', course.result)
        ..set("fixed",false)
        ..setACL(parseACL);
        await reportCourse.save();
    } else Future.delayed(Duration(seconds: 1));

    



    bottomSheetIsOpen = true;
    ignoreTimer = false;
    await showBottomSheetSuccess();
    ignoreTimer = true;
    if (!screnClosed){
      Navigator.pop(context);
    }
  }
  
  showBottomSheetSuccess(){
    return showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          )
        ),
        backgroundColor: prefix0.backgroundColor,
        builder: (builder){
          return new Container(
            height: 300,
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 180,
                  height: 180,
                  child: FlareActor("assets/check_animation.flr",
                    alignment:Alignment.center,
                    fit:BoxFit.contain, 
                    animation: "check",
                    callback: (string) async{
                      await Future.delayed(Duration(seconds: 3));

                      if (bottomSheetIsOpen && context != null) Navigator.pop(context); // FECHA BOTTOMSHEET
                      
                      if (!ignoreTimer && context != null) Navigator.pop(context); //FECHA ACTIVITY

                      if (!ignoreTimer && bottomSheetIsOpen) screnClosed = true;

                    },
                  )
                ),
                Text("Obrigado!",
                  style: TextStyle(color: prefix0.secondaryText, fontSize: 21, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 5),
                Text("Recebemos seu feedback e tentaremos resolver este problema o mais rápido possível.",
                  style: TextStyle(color: prefix0.tertiaryText, fontSize: 15,),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }
    );
    
  }
}