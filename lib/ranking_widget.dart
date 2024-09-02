import 'dart:ffi';
import 'package:flutterflow_ui/flutterflow_ui.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'ranking_model.dart';
export 'ranking_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'api_calls.dart';

class toSort{
  late String Name;
  var Above;
  var Below;
  late int Rot_Since_Pic;
  int Known = 0;
  late int id;
  var item_image;

  toSort(String Name_In, int id, var item_image) {
    this.Name = Name_In;
    this.Above = [];
    this.Below = [];
    this.Rot_Since_Pic = 0;
    this.Known = 0;
    this.id = id;
    this.item_image = item_image;
  }
  getName(){
    return this.Name;
  }
  getKnown()
  {
    return this.Known;
  }
}

class RankingWidget extends StatefulWidget {
  final overall_user_id;
  final overall_list_id;

  const RankingWidget({required this.overall_list_id, this.overall_user_id, super.key});


  @override
  State<RankingWidget> createState() => _RankingWidgetState();
}

class _RankingWidgetState extends State<RankingWidget> {
  late RankingModel _model;
  String item1 = "item 1";
  String item2 = "item 2";

  var item_list = [];
  var item_list_raw;
  var item1_obj;
  var item2_obj;
  var img_1 = "";
  var img_2 = "";
  double percentComplete = 0.0;
  String percentCompleteStr = "0.0%";

  //Everything gets initialized here.
  //Loop through and add a list of items here

  final scaffoldKey = GlobalKey<ScaffoldState>();
  
  get_list() async{
    var result = await http_post("list", {
      "list_id": widget.overall_list_id
    });

    if(result.ok){
      var in_list = result.data as List<dynamic>;
      print(in_list);
      //Go through and make objects for them.
      for(var i = 0; i<in_list.length; i++){
        item_list.add(toSort(in_list[i]["item_name"], in_list[i]["item_id"], in_list[i]["item_image"]));
      }
      print(item_list);
      pair();
    }
  }

  //Need to pass in the users ID to make this work.
  submit_ranking(var item_list_in) async{
    var result = await http_post("submit-ranking", {
      "user_id": widget.overall_user_id,
      "item_list": item_list_in
    });
    if(result.ok){
      print("Successfully Submitted.");
    }      
    print("About to close widget");
    Navigator.pop(context);
  }

  //Pair functionality:
  void pair(){
    for(var i = 0; i < item_list.length; i++){
      for(var g = 0; g < item_list[i].Above.length; g++){
        for(var q = 0; q < item_list[i].Above[g].Above.length; q++){
          if(!item_list[i].Above.contains(item_list[i].Above[g].Above[q])){
            item_list[i].Above.add(item_list[i].Above[g].Above[q]);
            item_list[i].Known++;
          } 
        }
      }
      for(var g = 0; g < item_list[i].Below.length; g++){
        for(var q = 0; q < item_list[i].Below[g].Below.length; q++){
          if(!item_list[i].Below.contains(item_list[i].Below[g].Below[q])){
            item_list[i].Below.add(item_list[i].Below[g].Below[q]);
            item_list[i].Known++;
          }
        }
      }
    }
    var known = 0;
    var total = item_list.length*(item_list.length - 1);
    for(var i = 0; i<item_list.length; i++){
      known += (item_list[i].Known as int);
    }
    percentComplete = known/total;
    if(known == total){
      //Generate List
      var final_list = [];
      for (var l = 0; l < item_list.length; l++){
        for (var p = 0; p < item_list.length; p++){
          if(item_list[p].Above.length == l){
            final_list.add(item_list[p].id);
          }
        }
      }
      print("Submitting Final List: " + final_list.toString());
      submit_ranking(final_list);
    }
    else{
      var possible_pairs = [];
      for (var i = 0; i < item_list.length; i++){
        var x = item_list[i];
        for(var g = 0; g < item_list.length; g++){
          var y = item_list[g];
          if(x != y){
            if(!(y.Above.contains(x) || y.Below.contains(y) || x.Above.contains(y) || x.Below.contains(y))){
              var weight = x.Known + y.Known - x.Rot_Since_Pic - y.Rot_Since_Pic;
              possible_pairs.add([weight, x, y]);
            }
          }
        }
      }
      var current_lowest = possible_pairs[0];
      for(var i = 0; i<possible_pairs.length; i++){
        if(possible_pairs[i][0] < current_lowest[0]){
          current_lowest = possible_pairs[i];
        }
      }
      item1_obj = current_lowest[1];
      item2_obj = current_lowest[2];
    }
    setState((){
      item1 = item1_obj.getName();
      item2 = item2_obj.getName();
      img_1 = item1_obj.item_image.toString();
      img_2 = item2_obj.item_image.toString();
      percentComplete;
      percentCompleteStr = (percentComplete*100).toInt().toString() + "%";
    });
  }

  //This will be changed into functionality loop.
  void updateRanking(int side){
    if(side == 1){
      item1_obj.Below.add(item2_obj);
      item1_obj.Known += 1;
      item2_obj.Above.add(item1_obj);
      item2_obj.Known += 1;
      item1_obj.Rot_Since_Pic = 0;
      item2_obj.Rot_Since_Pic = 0;
    }
    else{
      item2_obj.Below.add(item1_obj);
      item2_obj.Known += 1;
      item1_obj.Above.add(item2_obj);
      item1_obj.Known += 1;
      item1_obj.Rot_Since_Pic = 0;
      item2_obj.Rot_Since_Pic = 0;
    }

    //If 100% complete need to change things
    //runApp(MyApp()); - Not sure if this is right and have to be careful (if this works recursively) but helpful!
    pair();
    //Update Text and percents etc.

  }

  @override
  void initState() {
    print("Initialized");
    super.initState();
    _model = createModel(context, () => RankingModel());
    get_list();
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      home: Scaffold(
        key: scaffoldKey,
        body: SafeArea(
          top: true,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [

              Opacity(
                opacity: 0.95,
                child: InkWell(
                  child: Container(
                    width: MediaQuery.sizeOf(context).width * 1.0,
                    height: MediaQuery.sizeOf(context).height * 0.5,
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).secondaryBackground,
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: Image.network(
                          img_1,
                        ).image,
                      ),
                    ),
                    
                    child: Align(
                      alignment: AlignmentDirectional(0.0, 0.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).alternate,
                        ),
                        child: Text(
                          item1,
                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                                fontFamily: 'Readex Pro',
                                fontSize: 50.0,
                                letterSpacing: 0.0,
                              ),
                        ),
                      ),
                    ),
                  ),
                  onTap: (){
                    updateRanking(1);
                  }
                ),
              ),

              Container(
                height: MediaQuery.sizeOf(context).height * 0.5,
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: Image.network(
                      img_2,
                    ).image,
                  ),
                ),
                child: Opacity(
                  opacity: 0.95,
                  child: InkWell(
                  child: Stack(
                    children: [
                      Opacity(
                        opacity: 0.95,
                        child: Align(
                          alignment: AlignmentDirectional(-1.0, 1.0),
                          child: Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                10.0, 0.0, 0.0, 10.0),
                            child: CircularPercentIndicator(
                              percent: percentComplete,
                              radius: 35.0,
                              lineWidth: 5.0,
                              animation: true,
                              animateFromLastPercent: true,
                              progressColor:
                                  FlutterFlowTheme.of(context).primaryText,
                              backgroundColor:
                                  FlutterFlowTheme.of(context).accent4,
                              center: Text(
                                percentCompleteStr,
                                textAlign: TextAlign.start,
                                style: FlutterFlowTheme.of(context)
                                    .headlineSmall
                                    .override(
                                      fontFamily: 'Outfit',
                                      fontSize: 15.0,
                                      letterSpacing: 0.0,
                                    ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: AlignmentDirectional(0.0, 0.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context).alternate,
                          ),
                          child: Text(
                            item2,
                            style:
                                FlutterFlowTheme.of(context).bodyMedium.override(
                                      fontFamily: 'Readex Pro',
                                      fontSize: 50.0,
                                      letterSpacing: 0.0,
                                    ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  onTap: (){
                    updateRanking(2);
                  }
                ),
              ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
