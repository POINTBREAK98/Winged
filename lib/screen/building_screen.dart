import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:winged/models/floorplan_model.dart';
import 'package:winged/screen/building.dart';

class BuildingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<FloorPlanModel>(
            create: (context) => FloorPlanModel()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Building(),
      ),
    );
  }
}
