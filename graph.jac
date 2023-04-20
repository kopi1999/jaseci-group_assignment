// Edges
edge married;
edge child;
edge member;

// Nodes
node person {
    has uid;
    has family_id;
    has name;
    has date_of_birth;
    has profession;
    has gender;
    has deceased;
    has parents;
    has children;
    has spouse;
    has weight;
    has height;

    has age;
    has days_to_birthday;
    has get_weight;
    has get_height;
    has get_name;

    can get_age {
        today_date = date.date_now();
        difference = date.date_day_diff(start_date=date_of_birth, end_date=today_date);
        age = difference / 365;
    }

    can get_days_to_birthday {
        today_date = date.date_now();
        today_year = today_date.str::split('-')[0];
        birthdate_split = date_of_birth.str::split('-');
        birth_month = birthdate_split[1];
        birth_day = birthdate_split[2];
        birthday = '-'.str::join([today_year, birth_month, birth_day]);
        difference = date.date_day_diff(start_date=today_date, end_date=birthday);
        if (difference < 0) : difference = difference + 365;
        days_to_birthday = difference;
    }

    can get_weight {
        // return person's weight
        return here.weight;
    }

    can get_height {
        // return person's height
        return here.height;
    }

    can get_name {
        // return person's height
        return here.name;
    }
    // can calculate_bmi {
    //     // calculate BMI for the person
    //     weight = here.get_weight();
    //     height = here.get_height();
    //     bmi = weight / (height * height);
    //     std.out("BMI for " + here.name + " is: " + here.bmi);
    //     report bmi;
    // }
}
node family_root {
    has id;
    has family_name;
}

// Graphs
graph family_tree {
    has anchor family_root;
    spawn {
        family_root = spawn node::family_root;
    }
}