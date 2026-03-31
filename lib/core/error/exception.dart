class AppException implements Exception {
  String message;

  AppException(this.message);
}

class RemoteException extends AppException {
  RemoteException(super.message);
}


class LocalException extends AppException{
  LocalException(super.message);

}
