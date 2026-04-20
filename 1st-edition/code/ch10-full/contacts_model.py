import json
from operator import attrgetter
import time
from threading import Thread
from random import random


# ========================================================
# Contact Model
# ========================================================
PAGE_SIZE = 100

class Contact:
    # mock contacts database
    db = {}

    def __init__(self, id_=None, first=None, last=None, phone=None, email=None):
        self.id = id_
        self.first = first
        self.last = last
        self.phone = phone
        self.email = email
        self.errors = {}

    def __str__(self):
        return json.dumps(self.__dict__, ensure_ascii=False)

    def update(self, first, last, phone, email):
        self.first = first
        self.last = last
        self.phone = phone
        self.email = email

    def validate(self):
        if not self.email:
            self.errors['email'] = "Email Required"
        existing_contact = next(filter(lambda c: c.id != self.id and c.email == self.email, Contact.db.values()), None)
        if existing_contact:
            self.errors['email'] = "Email Must Be Unique"
        return len(self.errors) == 0

    def save(self):
        if not self.validate():
            return False
        if self.id is None:
            if len(Contact.db) == 0:
                max_id = 1
            else:
                max_id = max(contact.id for contact in Contact.db.values())
            self.id = max_id + 1
            Contact.db[self.id] = self
        Contact.save_db()
        return True

    def delete(self):
        del Contact.db[self.id]
        Contact.save_db()

    @classmethod
    def count(cls):
        time.sleep(2)
        return len(cls.db)

    @classmethod
    def all(cls, page=1):
        page = int(page)
        start = (page - 1) * PAGE_SIZE
        end = start + PAGE_SIZE
        return list(cls.db.values())[start:end]

    @classmethod
    def search(cls, text):
        result = []
        for c in cls.db.values():
            if text in c.first or text in c.last or text in c.email or text in c.phone:
                result.append(c)
        return result

    @classmethod
    def load_db(cls):
        with open('contacts.json', 'r') as contacts_file:
            contacts = json.load(contacts_file)
            cls.db.clear()
            for c in contacts:
                cls.db[c['id']] = Contact(c['id'], c['first'], c['last'], c['phone'], c['email'])

    @staticmethod
    def save_db():
        out_arr = [c.__dict__ for c in Contact.db.values()]
        with open("contacts.json", "w") as f:
            json.dump(out_arr, f, indent=2)

    @classmethod
    def find(cls, id_):
        id_ = int(id_)
        c = cls.db.get(id_)
        if c is not None:
            c.errors = {}

        return c


class Archiver:
    archive_status = "Waiting"
    archive_progress = 0
    thread = None

    def status(self):
        return Archiver.archive_status

    def progress(self):
        return Archiver.archive_progress

    def run(self):
        if Archiver.archive_status == "Waiting":
            Archiver.archive_status = "Running"
            Archiver.archive_progress = 0
            Archiver.thread = Thread(target=self.run_impl)
            Archiver.thread.start()

    def run_impl(self):
        for i in range(10):
            time.sleep(1 * random())
            if Archiver.archive_status != "Running":
                return
            Archiver.archive_progress = (i + 1) / 10
            print("Here... " + str(Archiver.archive_progress))
        time.sleep(1)
        if Archiver.archive_status != "Running":
            return
        Archiver.archive_status = "Complete"

    def archive_file(self):
        return 'contacts.json'

    def reset(self):
        Archiver.archive_status = "Waiting"

    @classmethod
    def get(cls):
        return Archiver()
