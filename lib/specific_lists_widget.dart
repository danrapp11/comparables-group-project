import 'package:flutter/gestures.dart';
import 'package:flutter_test_1/globals.dart';
import 'package:flutterflow_ui/flutterflow_ui.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'specific_lists_model.dart';
import 'api_calls.dart';
export 'specific_lists_model.dart';
import 'list_page_widget.dart';

class ListButton{
  final int list_id;
  final String img_url;
  final String list_name;

  ListButton(this.list_id, this.img_url, this.list_name);
}

class SpecificListsWidget extends StatefulWidget {
  final page_type;
  const SpecificListsWidget({required this.page_type, super.key});

  @override
  State<SpecificListsWidget> createState() => _SpecificListsWidgetState();
}

class _SpecificListsWidgetState extends State<SpecificListsWidget> {
  late SpecificListsModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  late List<ListButton> curr_items = [];

  setup() async{
    curr_items = [];
    var result = await http_post(widget.page_type, {
      "items_requested": 100
    });
    if(result.ok){
      for(var i = 0; i<result.data.length; i++){
        curr_items.add(ListButton(result.data[i]["list_id"], result.data[i]["item_image"].toString(), result.data[i]["list_name"]));
      }
    }
    setState(() {
      curr_items;
    });
  }

  @override
  void initState() {
    setup();
    super.initState();
    _model = createModel(context, () => SpecificListsModel());
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
          child: ListView(
            //mainAxisSize: MainAxisSize.max,
            children: [
              Align(
                alignment: AlignmentDirectional(0.0, 0.0),
                child: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text(
                    widget.page_type,
                    style: FlutterFlowTheme.of(context).headlineLarge.override(
                          fontFamily: 'Outfit',
                          letterSpacing: 0.0,
                        ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: FFButtonWidget(
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
                    textStyle: FlutterFlowTheme.of(context).titleSmall.override(
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
              ),
              SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: curr_items.map((ListButton){
                    return Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Opacity(
                          opacity: 0.8,
                          child: InkWell(
                          child: Padding(
                            padding: EdgeInsets.all(10.0),
                            child: InkWell(
                              splashColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              //onTap: () async {},
                              child: Container(
                                width: MediaQuery.sizeOf(context).width * 0.9,
                                height: 100.0,
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                  image: DecorationImage(
                                    fit: BoxFit.cover,
                                    alignment: AlignmentDirectional(0.0, 0.0),
                                    image: Image.network(
                                      ListButton.img_url,
                                    ).image,
                                  ),
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(0.0),
                                    bottomRight: Radius.circular(0.0),
                                    topLeft: Radius.circular(0.0),
                                    topRight: Radius.circular(0.0),
                                  ),
                                ),
                                child: Align(
                                  alignment: AlignmentDirectional(-1.0, -1.0),
                                  child: Padding(
                                    padding: EdgeInsets.all(4.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: FlutterFlowTheme.of(context)
                                            .alternate,
                                      ),
                                      child: Opacity(
                                        opacity: 0.9,
                                        child: Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  2.0, 1.0, 2.0, 1.0),
                                          child: Text(
                                            ListButton.list_name,
                                            textAlign: TextAlign.start,
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily: 'Readex Pro',
                                                  letterSpacing: 0.0,
                                                ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context) => ListPageWidget(overall_list_id: ListButton.list_id, overall_user_id: user_id_global),));
                          },
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
