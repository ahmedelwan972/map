abstract class MapStates{}

class InitState extends MapStates{}

class ChangeVisibilityState extends MapStates{}

class RegisterLoadingState extends MapStates{}

class RegisterErrorState extends MapStates{
  String e;
  RegisterErrorState(this.e);
}

class UserDataLoadingState extends MapStates{}

class UserDataSuccessState extends MapStates{
  String uId;
  UserDataSuccessState(this.uId);
}

class UserDataErrorState extends MapStates{}

class LoginLoadingState extends MapStates{}

class LoginSuccessState extends MapStates{
  String uId;
  LoginSuccessState(this.uId);
}

class LoginErrorState extends MapStates{
  String e;
  LoginErrorState(this.e);
}

class GetUserDateLoadingState extends MapStates{}

class GetUserDateSuccessState extends MapStates{}

class GetUserDateErrorState extends MapStates{
  String e;
  GetUserDateErrorState(this.e);
}
class GetAllUserDateLoadingState extends MapStates{}

class GetAllUserDateSuccessState extends MapStates{}

class GetAllUserDateErrorState extends MapStates{
  String e;
  GetAllUserDateErrorState(this.e);
}
class GetCurrentLocationLoadingState extends MapStates{}

class GetCurrentLocationState extends MapStates{}

class ChooseLocationState extends MapStates{}

class SelectDirectionSuccessState extends MapStates{}

class SelectDirectionErrorState extends MapStates{}

class SelectedDriverLoadingState extends MapStates{}

class SelectedDriverSuccessState extends MapStates{}

class SelectedDriverErrorState extends MapStates{}

class StartGoSuccessState extends MapStates{}

class StartOrderSuccessState extends MapStates{}

class CancelOrderSuccessState extends MapStates{}

class UpdateLocationToClientSuccessState extends MapStates{}

class UpdateLocationSuccessState extends MapStates{}

