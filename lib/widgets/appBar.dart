import 'package:flutter/material.dart';

class appBar extends StatelessWidget implements PreferredSizeWidget{
  const appBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(25),
              bottomRight: Radius.circular(25)
          )
      ),
      title: const Text('PC Remote Control'),
      backgroundColor: Colors.deepPurpleAccent,
      elevation: 0,
    );
  }


  @override
  Size get preferredSize => const Size.fromHeight(70.0);

}
