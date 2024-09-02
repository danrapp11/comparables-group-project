import 'dart:ffi';
import 'package:flutter/rendering.dart';
import 'package:flutterflow_ui/flutterflow_ui.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'ranking_widget.dart';
import 'package:intl/intl.dart';
import 'list_page_model.dart';
export 'list_page_model.dart';
import 'api_calls.dart';

class ListPageWidget extends StatefulWidget {
  final overall_user_id;
  final overall_list_id;
  const ListPageWidget({required this.overall_user_id, this.overall_list_id, super.key});

  @override
  State<ListPageWidget> createState() => _ListPageWidgetState();
}

class Item {
  final int item_id;
  final String item_name;
  final String avg_ranking;

  Item(this.item_id, this.item_name, this.avg_ranking);
}

class Friends_Ranking{
  final String friend_name;
  Friends_Ranking(this.friend_name);
}

class User_Ranking{
  final String item_name;
  final int item_rank;
  User_Ranking(this.item_name, this.item_rank);
}

class _ListPageWidgetState extends State<ListPageWidget> {
  late ListPageModel _model;

  late var list_name = "";
  late var author_name = ""; 
  late var date_created = '';
  late var rankings = 0;
  late var list_image = "";

  late List<User_Ranking> users_rankings = [];
  late List<Item> itemList= [];
  late List<User_Ranking> left_column = [];
  late List<User_Ranking> right_column = [];
  late List<Friends_Ranking> friend_who_have_ranked = [];

  final scaffoldKey = GlobalKey<ScaffoldState>();

  get_info() async{
    var result = await http_post("load-list-info", {
      "list_id": widget.overall_list_id,
      "user_id": widget.overall_user_id
    });
    if(result.ok){
      list_name = result.data[0]["list_name"];
      author_name = result.data[0]["user_name"];
      var date = result.data[0]["date_created"];
      date_created = (date.substring(5,7) + "/" + date.substring(8,10) + "/" + date.substring(0,4));
      rankings = result.data[2][0]["rank_count"];
      list_image = result.data[4][0]["item_image"].toString();
      print(result.data[1]);

      //Add this users rankings:
      left_column = [];
      right_column = [];
      itemList = [];
      for(var i = 0; i<result.data[3].length; i++){
        if(i < (result.data[3].length/2).ceil()){
          left_column.add(User_Ranking(result.data[3][i]["item_name"], result.data[3][i]["ranking"]));
        }
        else{
          right_column.add(User_Ranking(result.data[3][i]["item_name"], result.data[3][i]["ranking"]));
        }
      }
      //Split into two lists.


      //Adds the average ranking
      for(var i = 0; i<result.data[1].length; i++){
        if(i > 4){
          print("To Long!");
        }
        else{
          itemList.add(Item(result.data[1][i]["item_id"], result.data[1][i]["item_name"], result.data[1][i]["avg_ranking"]));
        }
      }
      //itemList = result.data[1];

      var result2 = await http_post("similarity", {
        "my_id": widget.overall_user_id,
        "list_id": widget.overall_list_id
      });
      if(result2.ok){
        for(var i = 0; i<result2.data.length; i++){
          friend_who_have_ranked.add(Friends_Ranking(result2.data[i]["user_name"]));
        }
      }
      print("Loaded Corretly");
      //Go through and add items into page.
      setState(() {
        list_name;
        rankings;
        list_image;
        friend_who_have_ranked;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    get_info();
    _model = createModel(context, () => ListPageModel());
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _model.unfocusNode.canRequestFocus
          ? FocusScope.of(context).requestFocus(_model.unfocusNode)
          : FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: SafeArea(
          top: true,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Column(
                mainAxisSize: MainAxisSize.max,
                children: [


                  Opacity(
                    opacity: 1,
                    child: Container(
                      width: MediaQuery.sizeOf(context).width * 1.0,
                      height: 200.0,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: Image.network(
                            list_image,
                          ).image,
                        ),
                      ),
                      child: Opacity(
                        opacity: 0.9,
                        child: Align(
                          alignment: AlignmentDirectional(0.0, 0.0),
                          child: Container(
                            decoration: BoxDecoration(color: FlutterFlowTheme.of(context).alternate,
                            ),
                            child: Text(
                              list_name,
                              textAlign: TextAlign.center,
                              style: FlutterFlowTheme.of(context)
                                  .titleLarge
                                  .override(
                                    fontFamily: 'Outfit',
                                    color: FlutterFlowTheme.of(context).primaryText,
                                    fontSize: 30.0,
                                    letterSpacing: 0.0,
                                  ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),


                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Text(
                              'Author:',
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    fontFamily: 'Readex Pro',
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryText,
                                    fontSize: 12.0,
                                    letterSpacing: 0.0,
                                  ),
                            ),
                            Text(
                              author_name,
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    fontFamily: 'Readex Pro',
                                    fontSize: 13.0,
                                    letterSpacing: 0.0,
                                  ),
                            ),
                          ],
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Text(
                              'Date Created:',
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    fontFamily: 'Readex Pro',
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryText,
                                    fontSize: 12.0,
                                    letterSpacing: 0.0,
                                  ),
                            ),
                            Text(
                              date_created.toString(),
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    fontFamily: 'Readex Pro',
                                    fontSize: 13.0,
                                    letterSpacing: 0.0,
                                  ),
                            ),
                          ],
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Text(
                              'Rankings:',
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    fontFamily: 'Readex Pro',
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryText,
                                    fontSize: 12.0,
                                    letterSpacing: 0.0,
                                  ),
                            ),
                            Text(
                              rankings.toString(),
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    fontFamily: 'Readex Pro',
                                    fontSize: 13.0,
                                    letterSpacing: 0.0,
                                  ),
                            ),
                          ],
                        ),
                      ].divide(SizedBox(width: 35.0)),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FFButtonWidget(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    text: 'Home',
                    options: FFButtonOptions(
                      height: 40.0,
                      padding:
                          EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
                      iconPadding:
                          EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                      color: FlutterFlowTheme.of(context).secondary,
                      textStyle:
                          FlutterFlowTheme.of(context).titleSmall.override(
                                fontFamily: 'Readex Pro',
                                color: Colors.white,
                                letterSpacing: 0.0,
                              ),
                      elevation: 3.0,
                      borderSide: BorderSide(
                        color: Colors.transparent,
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(0.0),
                    ),
                  ),
                  FFButtonWidget(
                    onPressed: () async {
                      await Navigator.push(context, MaterialPageRoute(builder: (context) => RankingWidget(overall_list_id: widget.overall_list_id, overall_user_id: widget.overall_user_id),));
                      get_info();
                      setState(() {
                        itemList;
                        users_rankings;
                        left_column;
                        right_column;
                      });
                    },
                    text: 'Rank',
                    options: FFButtonOptions(
                      height: 40.0,
                      padding:
                          EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
                      iconPadding:
                          EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                      color: FlutterFlowTheme.of(context).secondary,
                      textStyle:
                          FlutterFlowTheme.of(context).titleSmall.override(
                                fontFamily: 'Readex Pro',
                                color: Colors.white,
                                letterSpacing: 0.0,
                              ),
                      elevation: 3.0,
                      borderSide: BorderSide(
                        color: Colors.transparent,
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(0.0),
                    ),
                  ),
                ].divide(SizedBox(width: 75.0)),
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text(
                      'My Ranking:',
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'Readex Pro',
                            letterSpacing: 0.0,
                          ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: 
                    
                      left_column.map((User_Ranking) {
                        return Text(
                          '#${User_Ranking.item_rank} - ${User_Ranking.item_name}',
                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'Readex Pro',
                            letterSpacing: 0.0,
                          ),
                        );
                      }).toList(),

                  ),
                  Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children:                       
                      right_column.map((User_Ranking) {
                          return Text(
                            '#${User_Ranking.item_rank} - ${User_Ranking.item_name}',
                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'Readex Pro',
                              letterSpacing: 0.0,
                            ),
                          );
                      }).toList(),
                  ),
                ].divide(SizedBox(width: 50.0)),
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text(
                      'Top Ranking:',
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'Readex Pro',
                            letterSpacing: 0.0,
                          ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: 

                      itemList.map((item) {
                        return Text(
                          '${item.avg_ranking.substring(0,4)} - ${item.item_name}',
                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'Readex Pro',
                            letterSpacing: 0.0,
                          ),
                        );
                      }).toList(),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text(
                      'Friends Who have Ranked: ',
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'Readex Pro',
                            letterSpacing: 0.0,
                          ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: friend_who_have_ranked.map((Friends_Ranking) {
                      return                       Text(
                        Friends_Ranking.friend_name,
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'Readex Pro',
                              letterSpacing: 0.0,
                            ),
                      );
                    }).toList(),                
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
