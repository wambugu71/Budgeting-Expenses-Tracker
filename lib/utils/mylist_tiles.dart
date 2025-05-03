import 'package:flutter/material.dart';

class MylistTiles extends StatelessWidget{
  const MylistTiles({super.key});

  @override
  Widget build(BuildContext context) {
    return  ListTile(
         leading: Container(height: 50, width: 50,
         decoration: BoxDecoration(
           borderRadius: BorderRadius.circular(100), 
           color: Colors.white
         ),
         child: Icon(
           Icons.person
         ),),
       title: Text('Food'),
       subtitle: Text('spent'),
       trailing: Column(
        children: [
          Text('Spent:', 
          style: TextStyle(
            fontWeight: FontWeight.bold, 
            fontSize: 16
          ),
          ),
            Text('774', 
                      style: TextStyle(
             fontWeight: FontWeight.bold, 
             fontSize: 16
                      ),)
        ],
       ),
       );
    
  }
}