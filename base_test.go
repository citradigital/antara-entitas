package jidat_entitas

import (
	"time"

	"bytes"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"os"
	"path/filepath"
	"strconv"
	"testing"

	"github.com/stretchr/testify/assert"
)

type TestFixtures struct {
	Value string
	Time  time.Time
	Token string
	c     *entitas
}

func (f *TestFixtures) SetTime(t time.Time) {
	f.Time = t
}

func (f *TestFixtures) GetTime() time.Time {
	return f.Time
}

func (f *TestFixtures) SetValue(s string) {
	f.Value = s
}

func (f *TestFixtures) GetValue() string {
	return f.Value
}

func (f *TestFixtures) SetToken(s string) {
	f.Token = s
}

func (f *TestFixtures) GetToken() string {
	return f.Token
}

var fixtures Fixtures

func CreateFixtures() *TestFixtures {
	return &TestFixtures{Value: ""}
}

func testHttp(t *testing.T, method, url, token string, payload interface{}, checkResponse bool) (int, map[string]interface{}) {
	var err error
	var req *http.Request

	if method == "GET" || method == "DELETE" {
		req, err = http.NewRequest(method, url, nil)
	} else {
		jsonParam, err := json.Marshal(payload)
		if err != nil {
			t.Fatal(err)
		}
		var jsonStr = []byte(jsonParam)
		req, err = http.NewRequest(method, url, bytes.NewBuffer(jsonStr))
	}
	if err != nil {
		t.Fatal(err)
	}
	if token != "" {
		req.Header.Set("Authorization", "Bearer "+token)
	}

	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		t.Fatal(err)
	}

	if checkResponse == true {
		bodyBytes, _ := ioutil.ReadAll(resp.Body)
		bodyString := string(bodyBytes)

		var objmap map[string]interface{}
		if err := json.Unmarshal([]byte(bodyString), &objmap); err != nil {
			assert.Equal(t, true, false, "Should not be error")
		}
		return resp.StatusCode, objmap
	} else {
		return resp.StatusCode, nil
	}
}
