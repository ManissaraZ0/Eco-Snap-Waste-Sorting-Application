import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

Future<void> showProfilePickerDialog({
  required BuildContext context,
  required int selectedProfile,
  required Function(int) onSelected,
}) async {
  int tempSelected = selectedProfile;

  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            backgroundColor: Colors.yellow, // แทน TColor.marioYellow
            title: Text(
              'Choose Your Profile',
              style: TextStyle(
                color: Colors.black, // แทน TColor.marioBG
                fontWeight: FontWeight.bold,
              ),
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: GridView.builder(
                shrinkWrap: true,
                itemCount: 4,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                ),
                itemBuilder: (context, index) {
                  int profileNumber = index + 1;
                  bool isSelected = tempSelected == profileNumber;

                  return GestureDetector(
                    onTap: () {
                      setDialogState(() {
                        tempSelected = profileNumber;
                      });
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isSelected
                                  ? Colors.red
                                  : Colors.transparent,
                              width: 3,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: ColorFiltered(
                              colorFilter: isSelected
                                  ? ColorFilter.mode(
                                      Colors.black.withValues(alpha: .2),
                                      BlendMode.darken,
                                    )
                                  : const ColorFilter.mode(
                                      Colors.transparent,
                                      BlendMode.multiply,
                                    ),
                              child: Image.asset(
                                'assets/img/u$profileNumber.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        if (isSelected)
                          Positioned(
                            top: 6,
                            right: 6,
                            child: Icon(
                              Icons.check_circle,
                              color: Colors.greenAccent,
                              size: 28,
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "Cancel",
                  style: const TextStyle(color: Colors.black),
                ),
              ),
              TextButton(
                onPressed: () async {
                  var uid = FirebaseAuth.instance.currentUser?.uid;

                  // อัพเดต Firestore
                  await FirebaseFirestore.instance
                      .collection("users")
                      .doc(uid)
                      .update({
                        "profile_picture": "assets/img/u$tempSelected.png",
                      });

                  onSelected(tempSelected); // ให้หน้าแม่เปลี่ยน UI
                  // ignore: use_build_context_synchronously
                  Navigator.pop(context);
                },
                child: Text(
                  "Confirm",
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}
