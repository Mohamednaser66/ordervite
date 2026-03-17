import 'package:flutter/cupertino.dart';
import 'package:flutter_maps/models/address.dart';


class AppData extends ChangeNotifier{

late Address pickUpLocation,dropOffloction ;
  void updatePickUpLocationAddress( Address pickUpAddress){

        pickUpLocation=pickUpAddress;
        notifyListeners();
  }

    void updateDropOffLocationAddress( Address dropOffAddress){

        dropOffloction=dropOffAddress;
        notifyListeners();
  }

}