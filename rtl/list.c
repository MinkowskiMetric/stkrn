#include <rtl.h>

void InitializeListHead(ListEntry* head)
{
	head->Next = head;
	head->Prev = head;
}

void RemoveEntryList(ListEntry* entry)
{
	ASSERT(entry->Next != entry);
	ASSERT(entry->Prev != entry);
	
	entry->Next->Prev = entry->Prev;
	entry->Prev->Next = entry->Next;
}

void InsertListHead(ListEntry* list, ListEntry* entry)
{
	entry->Next = list->Next;
	entry->Prev = list;
	list->Next->Prev = entry;
	list->Next = entry;
}

void InsertListTail(ListEntry* list, ListEntry* entry)
{
	entry->Next = list;
	entry->Prev = list->Prev;
	list->Prev->Next = entry;
	list->Prev = entry;
}

int IsListEmpty(ListEntry* list)
{
	return (list->Next == list);
}
