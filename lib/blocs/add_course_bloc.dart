import 'dart:async';
import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:coursei/datas/course_data.dart';
import 'package:coursei/utils.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:rxdart/rxdart.dart';
enum PriceState{PAID_COURSE,FREE_COURSE}
enum PriceButtonState{DISABLED,ENABLED,LOADING,NEED_LOGIN,SUCCESSFULLY,NO_INTERNET_CONNECTION}
enum LinkPreviewState{IDLE,LOADING,ERROR,SUCCESSFULLY}
class AddCourseBloc extends BlocBase{
  final urlPattern = r"(https?|http)://([-A-Z0-9.]+)(/[-A-Z0-9+&@#/%=~_|!:,.;]*)?(\?[A-Z0-9+&@#/%=~_|!:‌​,.;]*)?";
  Timer _timer;
  String lastStringPreview = "";
   
  final _courseDataController = BehaviorSubject<CourseData>();
  final _priceState = BehaviorSubject<PriceState>.seeded(PriceState.FREE_COURSE);
  final _priceButtonState = BehaviorSubject<PriceButtonState>.seeded(PriceButtonState.DISABLED);
  final _linkPreviewState = BehaviorSubject<LinkPreviewState>.seeded(LinkPreviewState.IDLE);
  final _linkController = BehaviorSubject<String>();

  Stream<PriceState> get outPriceState => _priceState.stream;
  Stream<PriceButtonState> get outPriceButtonState => _priceButtonState.stream;
  Stream<LinkPreviewState> get outLinkPreviewState => _linkPreviewState.stream;
  Stream<CourseData> get outCourseData => _courseDataController.stream;
  Stream<String> get outLink => _linkController.stream;
  

  void validateLink(String url) {
    _linkController.sink.add(url);
    if (url.trim().length == 0) _linkPreviewState.sink.add(LinkPreviewState.IDLE);
    if (_timer != null) _timer.cancel();
    _timer = new Timer(Duration(milliseconds: 1000), () async{

      bool _validURL = Uri.parse(url).isAbsolute;

      if (_validURL) _priceButtonState.sink.add(PriceButtonState.ENABLED);
      
      else {
        _linkController.sink.addError("Insira um link válido");
        _priceButtonState.sink.add(PriceButtonState.DISABLED);
      } 

      if(lastStringPreview != _linkController.value && url.trim().length > 0 && _validURL){

        if (await hasInternetConnection(false))
            fetchCoursePreview(url);
        
      }
      

    });

  }



  void changePriceState(PriceState priceState){
    _priceState.sink.add(priceState);
    
  }

  void fetchCoursePreview(String url) async{
    lastStringPreview = url;
    _linkPreviewState.sink.add(LinkPreviewState.LOADING);
    final ParseCloudFunction function = ParseCloudFunction('fetchCourse');
    final Map<String, String> params = <String, String>{'url': url};
    final result = await function.execute(parameters: params);
    if (result.success) {

      final courseData = result.result;
      _linkPreviewState.sink.add(LinkPreviewState.SUCCESSFULLY);
      _courseDataController.sink.add(CourseData.fromMap(courseData));
      if (courseData["price"] != null && courseData["price"] > 0) _priceState.sink.add(PriceState.PAID_COURSE);
      else  _priceState.sink.add(PriceState.FREE_COURSE);

    }
    else _linkPreviewState.add(LinkPreviewState.ERROR);
  }

  void sendCourse() async{
    
    if (_priceButtonState.value != PriceButtonState.LOADING){
      String url = _linkController.value;
      bool hasInternet = await hasInternetConnection(false);
      if (!hasInternet) {
        _priceButtonState.sink.add(PriceButtonState.NO_INTERNET_CONNECTION);
        _priceButtonState.sink.add(PriceButtonState.ENABLED);
        return;
      }


      _priceButtonState.sink.add(PriceButtonState.LOADING);
      var user = await ParseUser.currentUser();
      if (user != null){
        String isPaid = (_priceState.value == PriceState.PAID_COURSE).toString();

        final ParseCloudFunction function = ParseCloudFunction('sendCourse');
        final Map<String, String> params = <String, String>{'url': url,"isPaid":isPaid};
        final result = await function.execute(parameters: params);

        if (result.success) {
          _priceButtonState.sink.add(PriceButtonState.SUCCESSFULLY); 
        }
             
      }
      else _priceButtonState.sink.add(PriceButtonState.NEED_LOGIN);
      
      
    }
    
  }

  ParseACL generateAcl(){
    ParseACL parseACL = ParseACL();
    parseACL.setPublicReadAccess(allowed: false);
    parseACL.setPublicWriteAccess(allowed: false);
    return parseACL;
  }

  @override
  void dispose() {
    _priceState.close();
    _priceButtonState.close();
    _linkPreviewState.close();
    _courseDataController.close();
    _linkController.close();
    super.dispose();
  }
}