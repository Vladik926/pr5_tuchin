import 'package:flutter/material.dart';
import '../models/note.dart';
import 'note_edit_screen.dart';

class NotesListScreen extends StatefulWidget {
  @override
  _NotesListScreenState createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> {
  List<Note> notes = [];
  List<Note> filteredNotes = [];
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  void _loadNotes() {
    // Здесь можно добавить загрузку из базы данных
    setState(() {
      filteredNotes = List.from(notes);
    });
  }

  void _filterNotes() {
    if (searchQuery.isEmpty) {
      setState(() {
        filteredNotes = List.from(notes);
      });
    } else {
      setState(() {
        filteredNotes = notes
            .where((note) =>
                note.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
                note.content.toLowerCase().contains(searchQuery.toLowerCase()))
            .toList();
      });
    }
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Поиск заметок'),
        content: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Введите заголовок или текст...',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            setState(() {
              searchQuery = value;
            });
            _filterNotes();
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                searchQuery = '';
                _searchController.clear();
              });
              _filterNotes();
              Navigator.pop(context);
            },
            child: Text('Очистить'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Готово'),
          ),
        ],
      ),
    );
  }

  void _addNote() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NoteEditScreen()),
    );

    if (result != null && result is Note) {
      setState(() {
        notes.insert(0, result);
        _filterNotes();
      });
      _showSnackBar('Заметка создана!');
    }
  }

  void _editNote(Note note) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NoteEditScreen(note: note)),
    );

    if (result != null && result is Note) {
      setState(() {
        final index = notes.indexWhere((n) => n.id == result.id);
        if (index != -1) {
          notes[index] = result;
          _filterNotes();
        }
      });
      _showSnackBar('Заметка обновлена!');
    }
  }

  void _deleteNote(String noteId) {
    final noteToDelete = notes.firstWhere((note) => note.id == noteId);
    setState(() {
      notes.removeWhere((note) => note.id == noteId);
      _filterNotes();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Заметка удалена'),
        action: SnackBarAction(
          label: 'Отмена',
          onPressed: () {
            setState(() {
              notes.insert(0, noteToDelete);
              _filterNotes();
            });
          },
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Мои заметки',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue[700],
        elevation: 0,
        actions: [
          if (searchQuery.isNotEmpty)
            Chip(
              label: Text('Найдено: ${filteredNotes.length}'),
              backgroundColor: Colors.white,
            ),
          IconButton(
            icon: Icon(Icons.search, color: Colors.white),
            onPressed: _showSearchDialog,
          ),
        ],
      ),
      body: filteredNotes.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.note_add,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 16),
                  Text(
                    searchQuery.isEmpty
                        ? 'Пока нет заметок'
                        : 'Заметки не найдены',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  if (searchQuery.isEmpty)
                    TextButton(
                      onPressed: _addNote,
                      child: Text('Создать первую заметку'),
                    ),
                ],
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: filteredNotes.length,
              itemBuilder: (context, index) {
                final note = filteredNotes[index];
                return _buildNoteCard(note, index);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNote,
        child: Icon(Icons.add, size: 30),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        elevation: 4,
      ),
    );
  }

  Widget _buildNoteCard(Note note, int index) {
    return Dismissible(
      key: Key(note.id),
      direction: DismissDirection.endToStart,
      background: Container(
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        child: Icon(Icons.delete, color: Colors.white, size: 30),
      ),
      onDismissed: (direction) => _deleteNote(note.id),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.only(bottom: 12),
        child: Container(
          decoration: BoxDecoration(
            color: note.color ?? Color(0xFFFFF0F5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.all(16),
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.blue[700]!.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.note,
                color: Colors.blue[700],
              ),
            ),
            title: Text(
              note.title.isEmpty ? 'Без названия' : note.title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 4),
                Text(
                  note.content.isEmpty ? 'Нет содержимого' : note.content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey[700]),
                ),
                SizedBox(height: 8),
                Text(
                  'Обновлено: ${_formatDate(note.updatedAt)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            trailing: IconButton(
              icon: Icon(Icons.delete_outline, color: Colors.grey[600]),
              onPressed: () => _deleteNote(note.id),
            ),
            onTap: () => _editNote(note),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Сегодня';
    } else if (difference.inDays == 1) {
      return 'Вчера';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} д. назад';
    } else {
      return '${date.day}.${date.month}.${date.year}';
    }
  }
}