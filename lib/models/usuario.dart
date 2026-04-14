class Usuario {
  String nome;
  String email;
  String avatarUrl;

  Usuario({
    required this.nome,
    required this.email,
    required this.avatarUrl,
  });

  Map<String, dynamic> toMap() => {
        'nome': nome,
        'email': email,
        'avatarUrl': avatarUrl,
      };

  factory Usuario.fromMap(Map<String, dynamic> map) => Usuario(
        nome: map['nome'] as String? ?? '',
        email: map['email'] as String? ?? '',
        avatarUrl: map['avatarUrl'] as String? ?? 'assets/avatar.png',
      );
}