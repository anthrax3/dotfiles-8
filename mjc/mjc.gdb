# Dump the handles cached by a session.
define find_dhandle
        set $conn = (WT_CONNECTION_IMPL *)session->iface.connection
        set $sid = 0
        while ($sid < $conn->session_cnt)
		set $session = &$conn->sessions[$sid]
		set $c = 0
		set $p = $session->dhandles->slh_first
		while ($p != 0)
			if ($p->dhandle == session->dhandle)
				printf "session %d, ", $sid
				printf "%d: %s", $c, $p->dhandle->name
				if ($p->dhandle->checkpoint != 0)
					printf " (%s)", $p->dhandle->checkpoint
				end
				printf " ref: %d, ", $p->dhandle->session_ref
				printf "inuse: %d, ", $p->dhandle->session_inuse
				printf "flags: 0x%x", $p->dhandle->flags
				printf "\n"
			end
			set $c = $c + 1
			set $p = ($p)->l.sle_next
		end
		set $sid = $sid + 1
	end
end
