class Supplier {
  final String? uid;
  Supplier({ this.uid });
}

class SupplierData{

  final String? id;
  final String? name;
  final String? email;
  final String? noHP;
  final String? mobile1;
   final String? mobile2;
  SupplierData({ this.id, this.name, this.email, this.noHP ,this.mobile1, this.mobile2});

  
  factory SupplierData.fromJson(Map<String, dynamic> json) {
    
    return SupplierData(
               id: json['id'],
               name: json['name'],
               email: json['email'],
               mobile1: json['mobile1'],
               mobile2: json['mobile2'],
   
    );
  }

}