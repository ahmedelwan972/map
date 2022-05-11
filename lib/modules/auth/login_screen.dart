import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:map/modules/auth/register_screen.dart';
import 'package:map/shared/local/cache_helper.dart';
import '../../layout/cubit/cubit.dart';
import '../../layout/cubit/states.dart';
import '../../layout/home_page_client_screen.dart';
import '../../layout/home_page_screen.dart';
import '../../shared/components/components.dart';
import '../../shared/components/constants.dart';

class LoginScreen extends StatelessWidget {
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MapCubit,MapStates>(
      listener: (context,state){
        if(state is LoginSuccessState){
          CacheHelper.saveData(key: 'uId', value: state.uId)
              .then((value) {
            uId = state.uId;
            MapCubit.get(context).getUserData().then((value){
              if(client!){
                navigateAndFinish(context, HomePageClientScreen());
              }else{
                navigateAndFinish(context, HomePageScreen());
              }
            });
          }).catchError((e){
            print('this is error ${e.toString()}');
          });
        }
        if(state is LoginErrorState){
          showToast(msg: 'المبينات المدخلة خطآ',toastState: true);
        }
      },
      builder: (context,state){
        return Scaffold(
          body: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:  [
                      const Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      const  SizedBox(
                        height: 20,
                      ),
                      defaultFormField(
                          controller: emailController,
                          label: 'البريد الالكتروني',
                          type: TextInputType.emailAddress,
                          suffix: Icons.email,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'ادخل البريد الالكتروني';
                            } else if (!value.contains('@') && !value.contains('.')) {
                              return 'البريد الالكتروني مدخل بشكل غير صحيح';
                            }
                          }),
                      const  SizedBox(
                        height: 10,
                      ),
                      defaultFormField(
                          controller: passwordController,
                          label: 'كلمة السر',
                          type: TextInputType.visiblePassword,
                          suffix: MapCubit.get(context).isPassword ? Icons.visibility : Icons.visibility_off,
                          isPassword: MapCubit.get(context).isPassword,
                          suffixPressed: (){
                            MapCubit.get(context).changeIsPassword();
                          },
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'ادخل كلمة السر';
                            }
                          }),
                      const  SizedBox(
                        height: 10,
                      ),
                      state is! LoginLoadingState?
                      defaultButton(
                        function: () {
                          if(formKey.currentState!.validate()){
                            MapCubit.get(context).login(
                              password: passwordController.text,
                              email: emailController.text,
                            );
                          }
                        },
                        text: 'تسجيل الدخول',
                      ): const Center(child: CircularProgressIndicator()),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () {
                              navigateTo(context, SignUpScreen());
                            },
                            child: const Text('سجل حساب الان  '),
                          ),
                          const Text('لا يوجد لديك حساب؟'),
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
