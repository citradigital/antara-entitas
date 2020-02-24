package jidat_entitas

import "time"

// Interface for injecting testing fixtures
type Fixtures interface {
	SetTime(t time.Time)
	GetTime() time.Time
	SetValue(s string)
	GetValue() string
}
