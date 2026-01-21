(define (problem lec-8-R4-S4-P40)
    (:domain lec-winter-split-macros)
    (:objects
        team-1 team-2 team-3 team-4 team-5 team-6 team-7 team-8 - team
        m1 m2 m3 m4 m5 m6 m7 - match
        ref-1 ref-2 ref-3 ref-4 - referee
        server-1 server-2 server-3 server-4 - server
    )
    (:init
        (ref-available ref-1)
        (ref-available ref-2)
        (ref-available ref-3)
        (ref-available ref-4)
        (server-available server-1)
        (server-available server-2)
        (server-available server-3)
        (server-available server-4)
        (participant team-1 m1 home)
        (participant team-2 m1 away)
        (participant team-3 m2 home)
        (participant team-4 m2 away)
        (participant team-5 m3 home)
        (participant team-6 m3 away)
        (participant team-7 m4 home)
        (participant team-8 m4 away)
        (connected m1 m5 home)
        (connected m2 m5 away)
        (connected m3 m6 home)
        (connected m4 m6 away)
        (connected m5 m7 home)
        (connected m6 m7 away)
        (has-conflict m2)
        (has-conflict m4)
        (has-conflict m5)
    )
    (:goal
        (verified m7)
    )
)