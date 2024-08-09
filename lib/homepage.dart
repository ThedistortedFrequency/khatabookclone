import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Row(
            children: [
              Text('Vyapar Group Tuition'),
              Icon(Icons.keyboard_arrow_down),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.calendar_today),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.person_add),
              onPressed: () {},
            ),
            // Add spacing between icons
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Customers'),
              Tab(text: 'Suppliers'),
            ],
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const Column(
                    children: [
                      Text('₹ 500',
                          style: TextStyle(fontSize: 20, color: Colors.green)),
                      Text('You will give'),
                    ],
                  ),
                  const Column(
                    children: [
                      Text('₹ 0',
                          style: TextStyle(fontSize: 20, color: Colors.red)),
                      Text('You will get'),
                    ],
                  ),
                  OutlinedButton(
                    onPressed: () {},
                    child: const Text('View Report'),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: TextField(
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Search Customer',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(25.0)),
                  ),
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  CustomerListView(),
                  const Center(child: Text('Suppliers')),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {},
          label: const Text(
            'Add Customer',
            style: TextStyle(color: Colors.white),
          ),
          icon: const Icon(Icons.person_add, color: Colors.white),
          backgroundColor: Colors.pink,
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.people),
              label: 'Parties',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt),
              label: 'Bills',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.inventory),
              label: 'Items',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.more_horiz),
              label: 'More',
            ),
          ],
          currentIndex: 0,
          selectedItemColor: Colors.indigo,
          unselectedItemColor: Colors.grey[500],
          onTap: (index) {},
        ),
      ),
    );
  }
}

class CustomerListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage('https://via.placeholder.com/150'),
          ),
          title: Text('Pritam'),
          subtitle: Text('10 days ago'),
          trailing: Text('₹ 500', style: TextStyle(color: Colors.green)),
        ),
        const ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage('https://via.placeholder.com/150'),
          ),
          title: Text('Cbum'),
          subtitle: Text('10 days ago'),
          trailing: Text('₹ 0', style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }
}
