
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'base_cell.dart';
import 'cell_event.dart';


class ExampleCell extends CellEvent
{

  final String title;
  final String detailTitle;
  final String time;
  final Image icon;
  final int badge;

   const ExampleCell({this.title='',this.detailTitle='',this.time='',this.icon,this.badge=0,
    GestureTapCallback tapCallback}):super(tapCallback:tapCallback);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    Widget child = Container(
      height: 70,
      padding: EdgeInsets.fromLTRB(14, 10, 14, 10),
      child:  Row(
        children: <Widget>[
          SizedBox(width: 45,height: 45,child: icon),
          Padding(padding: EdgeInsets.only(left: 12)),
          Expanded(child:
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children:<Widget>[
                  Expanded(
                    flex: 1,
                    child:Text(title,style: TextStyle(fontSize: 17.5,color: Colors.black87),overflow: TextOverflow.ellipsis,),
                  ),
                  Padding(padding: EdgeInsets.only(left: 2)),
                  Text(time,style: TextStyle(fontSize: 14,color: Color(0xFFAAAAAA)),),
                ],
              ),
              Padding(padding: EdgeInsets.only(top: 4)),
              Row(
                children:<Widget>[
                  Expanded(
                    flex: 1,
                    child:Text(detailTitle,style: TextStyle(fontSize: 14,color: Color(0xFFAAAAAA)),overflow: TextOverflow.ellipsis,),
                  ),
                  Padding(padding: EdgeInsets.only(top: 2)),
                  badge > 0 ? Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius:BorderRadius.all(Radius.circular(11)),
                        color: Colors.red,
                      ),
                      height: 22,
//                      color: Colors.red,
                      padding: EdgeInsets.only(left: 4,right: 4),
                      constraints: BoxConstraints(
                        minWidth: 22,
                      ),
                      child:
                      Text(badge > 99 ? '99+': badge.toString() ,style: TextStyle(fontSize: 11,color: Colors.white),)
                  ) :
                  Container(width: 0,height: 0,),
                ],
              ),

            ],
          )
          )
        ],
      ),
    );
    return BaseCell(child: child,tapCallback: tapCallback,);
  }



}