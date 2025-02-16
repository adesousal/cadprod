import 'package:flutter/material.dart';
import 'cadastro.dart';
import 'pesquisa.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cadastro de Produtos')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: Text('Novo'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Cadastro()),
                );
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text('Pesquisar'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Pesquisa()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
