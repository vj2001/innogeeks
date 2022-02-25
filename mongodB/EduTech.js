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
          },
          
          {
              userid: 2,
              username:"Nick Jonas",
          }
])

//fetch the data

db.students.find({}).pretty()

db.getCollection("students").find({userid:1})
db.getCollection("students").find({courses:{"$size":2}})            //size means count of array elements

db.getCollection("courses").find({}).pretty()
db.getCollection("sessions").find({}).pretty()

// update the data
db.courses.updateOne({courseid:"A119"},{$set:{coursename:"MongoDB"}})
db.courses.updateOne({coursename:"Python"},{$set:{coursename:"Python Programming"}})

db.students.updateOne({userid:1},{$set:{courses:[
                            { 
                                courseid:"A102",
                                coursename:"Linux",
                                sessions: 3,
                                instructor: "Mayur Patil",
                                assignments: 6
                            },
                            { 
                                courseid:"A122",
                                coursename:"Git",
                                sessions: 10,
                                instructor: "Mayur Patil",
                                assignments: 4
                            }
                      ]}})

//updating the courses for every student
db.students.updateOne({userid:2},{$set:{courses:[
                                { 
                                    courseid:"A119",
                                    coursename:"Databases",
                                    instructor:"R Gopal",
                                    sessions: 9,
                                    assignments:7
                                },
                                { 
                                    courseid:"A243",
                                    coursename:"Python",
                                    instructor:"Mayur Patil",
                                    sessions: 5,
                                    assignments:4
                                }
                      ]}})


//updating querie based on array matching for first occuring

db.students.updateMany({"courses.instructor":"Mr. Mayur Patil"},{$set:{"courses.$.instructor":"Mr. Mayur Sir"}}) 

//updating querie based on array matching for all elements

db.students.updateMany({},{$set:{"courses.$[ele].instructor":"Mr. Mayur Sir"}},
{arrayFilters:[{"ele.instructor":"Mayur Patil"}]})



//deleting the data
db.courses.deleteOne({coursename:"Git"})
db.courses.updateOne({coursename:"Linux"},{$set:{coursename:"MongoDB"}})

//deleting multiple data
db.courses.deleteMany({coursename:"MongoDB"})
db.courses.deleteMany({})



