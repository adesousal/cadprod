import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'cadastro.dart';

class Pesquisa extends StatefulWidget {
  const Pesquisa({Key? key}) : super(key: key);

  @override
  _PesquisaState createState() => _PesquisaState();
}

class _PesquisaState extends State<Pesquisa> {
  List<dynamic> produtos = [];
  List<dynamic> produtosFiltrados = [];

  final TextEditingController _codigoController = TextEditingController();
  final TextEditingController _corController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    carregarProdutos();
  }

  Future<File> get _localFile async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/produtos.json');
  }

  Future<void> carregarProdutos() async {
    try {
      final file = await _localFile;
      if (!file.existsSync()) {
        setState(() {
          produtos = [];
          produtosFiltrados = [];
        });
        return;
      }
      String contents = await file.readAsString();
      setState(() {
        produtos = json.decode(contents);
        produtosFiltrados = produtos;
      });
    } catch (e) {
      setState(() {
        produtos = [];
        produtosFiltrados = [];
      });
    }
  }

  void filtrarProdutos() {
    String codigo = _codigoController.text;
    String cor = _corController.text;
    String descricao = _descricaoController.text;

    setState(() {
      produtosFiltrados = produtos.where((produto) {
        bool matches = true;
        if (codigo.isNotEmpty) {
          matches = matches && produto['codigo'].contains(codigo);
        }
        if (cor.isNotEmpty) {
          matches = matches &&
              produto['cor']
                  .toString()
                  .toLowerCase()
                  .contains(cor.toLowerCase());
        }
        if (descricao.isNotEmpty) {
          matches = matches &&
              produto['descricao']
                  .toString()
                  .toLowerCase()
                  .contains(descricao.toLowerCase());
        }
        return matches;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pesquisar Produtos'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Campos de filtro
            TextField(
              controller: _codigoController,
              decoration: InputDecoration(labelText: 'Código'),
              keyboardType: TextInputType.number,
              onChanged: (value) => filtrarProdutos(),
            ),
            TextField(
              controller: _corController,
              decoration: InputDecoration(labelText: 'Cor'),
              onChanged: (value) => filtrarProdutos(),
            ),
            TextField(
              controller: _descricaoController,
              decoration: InputDecoration(labelText: 'Descrição'),
              onChanged: (value) => filtrarProdutos(),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: produtosFiltrados.length,
                itemBuilder: (context, index) {
                  var produto = produtosFiltrados[index];
                  return ListTile(
                    title: Text(produto['descricao']),
                    subtitle: Text(
                        'Código: ${produto['codigo']} - Cor: ${produto['cor']}'),
                    onTap: () async {
                      // Navega para a tela de cadastro para visualização/edição
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Cadastro(produto: produto),
                        ),
                      );
                      carregarProdutos();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}