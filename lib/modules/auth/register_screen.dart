import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:map/layout/home_page_screen.dart';
import '../../layout/cubit/cubit.dart';
import '../../layout/cubit/states.dart';
import '../../shared/components/components.dart';
import '../../shared/components/constants.dart';
import '../../shared/local/cache_helper.dart';

class SignUpScreen extends StatelessWidget {
  var userNameController = TextEditingController();
  var emailController = TextEditingController();
  var phoneController = TextEditingController();
  var passwordController = TextEditingController();
  var password2Controller = TextEditingController();
  var formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MapCubit,MapStates>(
      listener: (context,state){
        if(state is UserDataSuccessState){
          CacheHelper.saveData(key: 'uId', value: state.uId)
              .then((value) {
                uId = state.uId;
            MapCubit.get(context).getUserData();
            navigateAndFinish(context, HomePageScreen());
          }).catchError((e){
            print('this is error ${e.toString()}');
          });
        }
        if(state is RegisterErrorState){
          showToast(msg:'المبينات المدخلة خطآ',toastState: true);
        }
      },
      builder: (context,state){
        var cubit = MapCubit.get(context);
        return Scaffold(
          body: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                     const Text(
                        'Register',
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      const  SizedBox(
                        height: 20,
                      ),
                      defaultFormField(
                          controller: userNameController,
                          label: 'الاسم',
                          type: TextInputType.text,
                          suffix: Icons.person,
                          validator: (value) {
                            if (value.isEmpty) {
                              'ادخل الاسم';
                            }
                          }),
                      const SizedBox(
                        height: 10,
                      ),
                      defaultFormField(
                          controller: emailController,
                          label: 'البريد الالكتروني',
                          type: TextInputType.emailAddress,
                          suffix: Icons.email,
                          validator: (value) {
                            if (value.isEmpty) {
                              'ادخل البريد الالكتروني';
                            } else if (!value.contains('@')) {
                              return 'البريد الالكتروني مدخل بشكل غير صحيح';
                            }else  if(!value.contains('.')){
                              return 'البريد الالكتروني مدخل بشكل غير صحيح';
                            }
                          }),
                      const  SizedBox(
                        height: 10,
                      ),
                      defaultFormField(
                          controller: phoneController,
                          label: 'رقم الهاتف',
                          type: TextInputType.phone,
                          suffix: Icons.phone_android,
                          validator: (value) {
                            if (value.isEmpty) {
                              'ادخل رقم الهاتف';
                            }
                          }),
                      const SizedBox(
                        height: 10,
                      ),
                      defaultFormField(
                        controller: passwordController,
                        label: 'كلمة السر',
                        type: TextInputType.visiblePassword,
                        suffix: cubit.isPasswordS ? Icons.visibility : Icons.visibility_off,
                        isPassword: cubit.isPasswordS,
                        suffixPressed: (){
                          cubit.changeIsPasswordS();
                        },
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'ادخل كلمة السر';
                          } else if (value.length < 8) {
                            return ' كلمة السر ضعيفة';
                          }
                        },
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      defaultFormField(
                        controller: password2Controller,
                        label: 'تاكيد كلمة السر',
                        type: TextInputType.visiblePassword,
                        suffix: cubit.isPasswordSC ? Icons.visibility : Icons.visibility_off,
                        isPassword: cubit.isPasswordSC,
                        suffixPressed: (){
                          cubit.changeIsPasswordSC();
                        },
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'ادخل كلمة السر';
                          } else if (value.length < 8) {
                            return ' كلمة السر ضعيفة';
                          } else if (password2Controller.text !=
                              passwordController.text) {
                            return ' كلمة السر غير متطابقة';
                          }
                        },
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Checkbox(
                              value: cubit.isDriver,
                              onChanged: (value){
                                cubit.isDriver = !cubit.isDriver;
                                print(cubit.isDriver);
                                cubit.emitS();
                              },
                          ),
                         const SizedBox(width: 15,),
                          const Text('هل انت سائق'),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      state is! RegisterLoadingState ?
                      defaultButton(
                        function: () {
                          if(formKey.currentState!.validate()){
                            cubit.register(
                              email: emailController.text,
                              name: userNameController.text,
                              phone: phoneController.text,
                              password: passwordController.text,
                            );
                          }
                        },
                        text: 'انشاة حساب',
                      ): const Center(child: CircularProgressIndicator()),
                      const  SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child:const Text('رجوع'),
                          ),
                          const Text('لديك حساب بالفعل؟'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
