// courses list

db.courses.insertMany([
        { 
            courseid:"A102",
            coursename:"Linux"
        },
        { 
            courseid:"A122",
            coursename:"Git"
        },
        {
            courseid:"A119",
            coursename:"Databases"
        },
        { 
            courseid:"A243",
            coursename:"Python"
        }
])

// sessions list
db.sessions.insertMany(
[
        {
           sessionid: 1,
           instructor: "Mayur Patil",
                       course:  { 
                        courseid:"A102",
                        coursename:"Linux"
                    }, 
        },
        {
           sessionid: 2,
           instructor: "Mayur Patil",
                       course:  { 
                        courseid:"A243",
                        coursename:"Python"
                    }
        }
]
)

// students list

db.students.insertMany(
[
          {
              userid: 1,
              username:"Vishal Jain",
              courses:[
                            { 
                                courseid:"A102",
                                coursename:"Linux",
                                session: {
                                           sessionid: 1,
                                           instructor: "Mayur Patil",
                                         }
                            },
                            { 
                                courseid:"A122",
                                coursename:"Git"
                            }
                      ],
               
          },
          
          {
              userid: 2,
              username:"Nick Jonas",
              courses:[
                                { 
                                    courseid:"A119",
                                    coursename:"Databases"
                                },
                                { 
                                    courseid:"A243",
                                    coursename:"Python",
                                    session: {
                                               sessionid: 2,
                                               instructor: "Mayur Patil",         
                                             }
                                }
                      ],
              
          }
]
)