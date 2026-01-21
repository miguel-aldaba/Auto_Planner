(define (problem lec-4-R4-S4-P40)
    (:domain lec-winter-split-macros)
    (:objects
        team-1 team-2 team-3 team-4 - team
        m1 m2 m3 - match
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
        (connected m1 m3 home)
        (connected m2 m3 away)
        (has-conflict m2)
        (has-conflict m3)
    )
    (:goal
        (verified m3)
    )
)