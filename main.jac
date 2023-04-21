import {*} with "./graph.jac";

walker create_familytree {
    // creates a familytree from a json file
    has data_file = "family_tree.json";
    has famly_members = [];

    root {
        families = file.load_json(data_file)["families"];
        for family in families {
            spawn here ++> node::family_root(
                id = family["uid"],
                family_name = family["family_name"]
            );
        }
        take-->node::family_root;
    }

    family_root {
        family_id = here.id;
        members = file.load_json(data_file)["members"];
        filtered_members = [];
        for member in members {
            if (member["family_id"] == family_id) {
                filtered_members.list::append(member);
            }
        }
        for member in filtered_members {
            family_member = spawn here +[member]+> node::person(
                id = member["uid"],
                family_id = member["family_id"],
                name = member["name"],
                date_of_birth = member["date_of_birth"],
                profession = member["profession"],
                gender = member["gender"],
                deceased = member["deceased"],
                parents = member["parents"],
                children = member["children"],
                spouse = member["spouse"],
                sports = member["sports"]
            );
            famly_members.list::append(family_member);
        }
    }

    with exit {
        for member_1 in famly_members {
            for member_2 in famly_members {
                if (member_1.id  == member_2.id): continue;
                if (member_1.spouse == member_2.id and member_2.spouse == member_1.id) {
                    member_1 +[married]+> member_2;
                }
                if (member_1.id in member_2.children): member_1 +[child]+> member_2;
            }
        }
    }
}

walker find_coming_birthday {
    // returns the upcoming birthdays of the family
    has max_return = 5;
    has anchor birthday_order = [];

    root: take-->node::family_root;
    family_root: take-->node::person;
    person {
        if (!here.deceased) {
            here::get_days_to_birthday;
            here::get_age;
            birthday_order.l::append([here.days_to_birthday, here.age, here.name]);
        }
    }
    with exit {
        birthday_order = std.sort_by_col(birthday_order, 0);
        birthday_order = birthday_order[0:max_return];
        std.out(birthday_order);
        report birthday_order;
    }

}
walker find_similar_sport_interests {
        has max_return = 5;
        has anchor sports_dict = {};
        
        root: take-->node::family_root;
        family_root: take-->node::person;
        person {
            for sports in here.hobbies {
                if (sports not in sports_dict) {
                    sports_dict[sports] = [];
                }
                sports_dict[sports].list::append(here.name);
            }
        }
        with exit {
            std.out(sports_dict);
            report sports_dict;
        }
}

walker calculate_bmi {
    // calculates BMI for all family members. 
    has max_return = 5;
    has anchor bmi_order = [];

    root: take-->node::family_root;
    family_root: take-->node::person;
    person {
        if (!here.deceased) {
            here::get_age;
            here::get_bmi;
            bmi_order.l::append([here.bmi, here.age, here.name]);
        }
    }
    with exit {
        bmi_order = std.sort_by_col(bmi_order, 0);
        bmi_order = bmi_order[0:max_return];
        std.out(bmi_order);
        report bmi_order;
    }
}