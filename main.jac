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
    //Comment
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
                height = member["height"],
                weight = member["weight"],
                hobbies = member["hobbies"],
                education = member["education"],
                status = member["status"]

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

walker find_BMI {
    // returns the upcoming birthdays of the family
    has anchor BMI_List = [];
    has anchor BMI_test = [];


    root: take-->node::family_root;
    family_root: take-->node::person;
    person {
        if (true) {
            here::get_BMI;
            BMI_List.list::append(here.BMI);

            if (here.BMI > 25){
                BMI_test.list::append(" ".str::join([here.name," you are in over weight"]));
            }
            if (here.BMI > 18.5 and here.BMI <25){
                BMI_test.list::append(" ".str::join([here.name," you are in normal weight"]));
            }
            if (here.BMI <18.5){
                BMI_test.list::append(" ".str::join([here.name," you are in under weight"]));
            }
        }
    }
    with exit {
        std.out(BMI_test);
        report BMI_test;
        }
}

walker each_hobby_and_persons {
    has max_return = 5;
    has anchor hobbies_dict = {};

    root: take-->node::family_root;
    family_root: take-->node::person;
    person {
        for hobby in here.hobbies {
            if (hobby not in hobbies_dict) {
                hobbies_dict[hobby] = [];
            }
            hobbies_dict[hobby].list::append(here.name);
        }
    }
    with exit {
        std.out(hobbies_dict);
        report hobbies_dict;
    }
}

walker show_graguated {
    // show whe are the graduated family members.  
    has max_return = 5;
    has anchor graduated_dict = {};

    root: take-->node::family_root;
    family_root: take-->node::person;
    
    person {
        for educations in here.education {
            if (educations == "graduate") {
                graduated_dict[educations] = [];
            }
            greduated_dict[educations].list::append(here.name);
        }
    }
    with exit {
        std.out(graduated_dict);
        report graduated_dict;
    }
}

walker married_lists{
    has anchor married_list=[];
    root: take-->node::family_root;
    family_root: take-->node::person;
    person {
        if (here.status=="married"){
        married_list.list::append(here.name);}

    }
    with exit{
        report married_list;
    }
}
