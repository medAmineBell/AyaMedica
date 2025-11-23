import 'package:flutter_getx_app/models/gardes.dart';
import 'package:get/get.dart';

class GardesController extends GetxController {
  final RxList<Gardes> gardes = <Gardes>[].obs;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    // addGarder();
  }

  void addGarder() {
    gardes.addAll([
      Gardes(
          id: '1',
          NumClasses: 4,
          MaxCapacity: 35,
          ClassName: "Lions",
          ActualCapacity: 22,
          name: "Grade - G1"),
      Gardes(
          id: '1',
          NumClasses: 4,
          MaxCapacity: 35,
          ClassName: "Lions",
          ActualCapacity: 22,
          name: "Grade - G1"),
      Gardes(
          id: '1',
          NumClasses: 4,
          MaxCapacity: 35,
          ClassName: "Lions",
          ActualCapacity: 22,
          name: "Grade - G1"),
      Gardes(
          id: '1',
          NumClasses: 4,
          MaxCapacity: 35,
          ClassName: "Lions",
          ActualCapacity: 22,
          name: "Grade - G1"),
    ]);
  }
}
