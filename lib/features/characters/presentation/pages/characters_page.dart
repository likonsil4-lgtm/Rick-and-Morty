
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/characters_cubit.dart';

class CharactersPage extends StatefulWidget {
  const CharactersPage({super.key});

  @override
  State<CharactersPage> createState() => _CharactersPageState();
}

class _CharactersPageState extends State<CharactersPage> {

  @override
  void initState() {
    super.initState();
    // refresh data when entering screen
    context.read<CharactersCubit>().loadCharacters();
  }

  Future<void> _refresh() async {
    await context.read<CharactersCubit>().loadCharacters();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Characters")),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: const Center(child: Text("Characters list here")),
      ),
    );
  }
}
