(define (domain lec-winter-split-macros)
    (:requirements :strips :typing :equality :negative-preconditions)
    (:types match team referee server slot - object)
    (:constants home away - slot)

    (:predicates
        (connected ?m1 - match ?m2 - match ?s - slot)
        (participant ?t - team ?m - match ?s - slot)
        (ref-available ?r - referee)
        (server-available ?s - server)
        
        ;; Predicados de estado necesarios para el grafo
        (verified ?m - match) 
        (winner-determined ?m - match)
        (winner ?m - match ?t - team)
        
        ;; Flag de control
        (has-conflict ?m - match)
    )

    ;; MACRO 1: Partido Normal Completo
    ;; Secuencia: Draft -> PlayClean -> Sign -> Verify
    (:action macro-complete-match-clean
        :parameters (?m - match ?s - server ?r - referee ?t - team)
        :precondition (and 
            (participant ?t ?m home) ;; Asumimos gana home
            (not (verified ?m))
            (ref-available ?r)
            (server-available ?s)
            (not (has-conflict ?m))  ;; Solo si NO hay conflicto
        )
        :effect (and 
            (verified ?m)
            (winner-determined ?m)
            (winner ?m ?t)
            ;; Los recursos entran y salen, el estado neto es neutral
        )
    )

    ;; MACRO 2: Partido con Incidencia Resuelta (Ruling)
    ;; Secuencia: Draft -> PlayBug -> Protest -> RulingConfirm -> Sign -> Verify
    (:action macro-complete-match-with-ruling
        :parameters (?m - match ?s - server ?r - referee ?t - team)
        :precondition (and 
            (participant ?t ?m home)
            (not (verified ?m))
            (ref-available ?r)
            (server-available ?s)
            (has-conflict ?m)        ;; Solo si HAY conflicto
        )
        :effect (and 
            (verified ?m)
            (winner-determined ?m)
            (winner ?m ?t)
        )
    )

    ;; MACRO 3: Partido con Replay (Costoso)
    ;; Secuencia: Draft -> PlayBug -> Protest -> Replay -> PlayClean -> Sign -> Verify
    ;; Nota: Esta macro asume que tras el replay se juega limpio.
    (:action macro-complete-match-with-replay
        :parameters (?m - match ?s - server ?r - referee ?t - team)
        :precondition (and 
            (participant ?t ?m home)
            (not (verified ?m))
            (ref-available ?r)
            (server-available ?s)
            (has-conflict ?m)        ;; Se dispara por conflicto
        )
        :effect (and 
            (verified ?m)
            (winner-determined ?m)
            (winner ?m ?t)
            ;; En un modelo con costes, aquí pondrías (increase (total-cost) 50)
        )
    )

    ;; MACRO 4: No Show (Administrativo)
    (:action macro-admin-noshow
        :parameters (?m - match ?t - team)
        :precondition (and 
            (participant ?t ?m home)
            (not (verified ?m))
            ;; No requiere recursos
        )
        :effect (and 
            (verified ?m)
            (winner-determined ?m)
            (winner ?m ?t)
        )
    )

    ;; Acción de Avanzar (Igual que en el normal)
    (:action promote-to-next-round
        :parameters (?m_src - match ?m_dst - match ?t - team ?s - slot)
        :precondition (and 
            (winner-determined ?m_src)
            (winner ?m_src ?t)
            (connected ?m_src ?m_dst ?s)
        )
        :effect (and 
            (participant ?t ?m_dst ?s)
        )
    )
)