import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:map/layout/cubit/cubit.dart';

Widget defaultButton({
  double width = double.infinity,
  bool isUpperCase = true,
  double radius = 20.0,
  Color color = Colors.green,
  required Function function,
  required String text,
}) =>
    Container(
      width: width,
      height: 50.0,
      child: MaterialButton(
        child: Text(
          isUpperCase ? text.toUpperCase() : text,
          style:const TextStyle(
            color: Colors.white,
          ),
        ),
        onPressed: () {
          function();
        },
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
      ),
    );

void navigateTo(context, widget) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => widget,
    ),
  );
}

void navigateAndFinish(context, widget) {
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(
      builder: (context) => widget,
    ),
    (route) => false,
  );
}

Widget defaultFormField({
  String? text,
  required TextEditingController controller,
  bool isPassword = false,
  FormFieldValidator? validator,
  TextInputType? type,
  String? label,
  bool enabled = true,
  Function? suffixPressed,
  IconData? suffix,
  IconData? prefix,
}) =>
    TextFormField(
      obscureText: isPassword,
      enabled: enabled,
      controller: controller,
      keyboardType: type,
      decoration: InputDecoration(
        isDense: true,
        hintText: text,
        labelText: label,
        prefix: Icon(prefix),
        suffixIcon: suffix != null
            ? IconButton(
                onPressed: () {
                  {
                    if (suffixPressed != null) suffixPressed();
                  }
                },
                icon: Icon(suffix),
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      validator: validator,
    );

Future<bool?> showToast({required String msg, bool? toastState}) =>
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 5,
        backgroundColor: toastState != null
            ? toastState
                ? Colors.yellow[900]
                : Colors.red
            : Colors.green,
        textColor: Colors.white,
        fontSize: 16.0);







Future openDialog(context,snapshot) {
  return showModalBottomSheet(context: context,barrierColor: Colors.transparent, builder: (context)=>
      Column(
        children: [
          const Text('Order await',),
          Container(
            height: 500,
            width: double.infinity,
            child: ListView.separated(
              itemBuilder: (context,index)=>buildOrderItem(snapshot[index],context),
              separatorBuilder: (context,index)=>const SizedBox(height: 3,),
              itemCount: snapshot.length,
            ),
          ),
        ],
      ),
  );}

TextStyle textStyle = const TextStyle(
  fontWeight: FontWeight.w500,
  fontSize: 14,
  color: Colors.white,
  shadows: [
    Shadow(
      color: Colors.black,
      blurRadius: 4,
      offset: Offset(0,2),
    ),
    Shadow(
      color: Colors.blue,
      blurRadius: 4,
      offset: Offset(0,2),
    ),
  ],
);

buildOrderItem(data,context){
  if(!data['isSelected']){
    print(data);
    return Container(
      height: 240,
      width: 220,
      padding: const EdgeInsets.all(20.0),
      child: Card(
        color: Colors.blue[900],
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Name : ${data['name']}',maxLines: 1,style: textStyle,),
              Text('From : ${data['from']}',maxLines: 2,style: textStyle,),
              Text('to : ${data['to']}',maxLines: 2,style: textStyle,),
              defaultButton(function: (){
                MapCubit.get(context).orderAgreed();
                Navigator.pop(context);
              }, text: 'Agree Order')
            ],
          ),
        ),
      ),
    );
  } else{
    print('error');
    return Container();
  }
}



