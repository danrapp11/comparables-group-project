import 'package:flutterflow_ui/flutterflow_ui.dart';

import 'specific_lists_widget.dart' show SpecificListsWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class SpecificListsModel extends FlutterFlowModel<SpecificListsWidget> {
  ///  State fields for stateful widgets in this page.

  final unfocusNode = FocusNode();

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    unfocusNode.dispose();
  }
}
